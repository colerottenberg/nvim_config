-- Custom avante.nvim Bedrock model handler for NVIDIA Nemotron Super 3 120B.
--
-- avante.nvim's built-in Bedrock provider (lua/avante/providers/bedrock.lua in the
-- plugin) only ships a request/response handler for Anthropic Claude models
-- (lua/avante/providers/bedrock/claude.lua), which speaks the raw Anthropic
-- `invoke-with-response-stream` wire format. Nemotron doesn't speak that format, so
-- this file is loaded instead: avante resolves the handler module by turning the
-- configured `model` id into a require() path (dots -> path separators), so
-- model = "nvidia.nemotron-super-3-120b" resolves to
-- avante/providers/bedrock/nvidia/nemotron-super-3-120b.lua. Because this path
-- lives under ~/.config/nvim/lua (on Neovim's runtimepath), it shadows/extends the
-- plugin's own bedrock/ directory without touching avante's installed source.
--
-- This handler uses Bedrock's Converse API instead: unlike raw invoke_model, Converse
-- has one standardized request/response schema across every Bedrock model, so it
-- works for Nemotron without needing NVIDIA-specific wire-format docs. It's wired up
-- for the *non-streaming* Converse endpoint (not ConverseStream): avante's shared
-- stream-chunk decoder (parse_stream_data, in the plugin's bedrock.lua) is hardcoded
-- to Claude's base64 "bytes" envelope and isn't per-model overridable, so token-by-
-- token streaming isn't available here. The full reply arrives in one shot instead
-- of streaming in -- functionally everything else (chat, agentic edits, tool calls)
-- still works.
--
-- Requires providers.bedrock.endpoint in the lazy.nvim config to point at the
-- `/converse` (not `/converse-stream` or `/invoke*`) path for this model+region.

local Utils = require("avante.utils")

---@class AvanteBedrockModelHandler
local M = {}

M.support_prompt_caching = false
M.role_map = {
  user = "user",
  assistant = "assistant",
}

-- Tells avante's transport (lua/avante/llm.lua) to call parse_response_without_stream
-- on the full response body instead of streaming deltas through parse_response.
function M.is_disable_stream() return true end

-- Converse's event-stream framing differs from the Claude/invoke_model framing that
-- avante's shared stream-chunk decoder expects, so streaming chunks are not
-- meaningful here. Defined as a safe no-op in case the decoder ever calls it.
function M.parse_response(_, _ctx, _data_stream, _event_state, _opts) end

---@param self AvanteBedrockProviderFunctor
---@param opts AvantePromptOptions
---@return table[] Converse-format messages
function M.parse_messages(self, opts)
  local messages = {}

  local function add_text(list, text, role)
    if role == "assistant" then text = text:gsub("%s+$", "") end
    if text ~= "" then table.insert(list, { text = text }) end
  end

  for _, message in ipairs(opts.messages) do
    local content_items = message.content
    local message_content = {}

    if type(content_items) == "string" then
      add_text(message_content, content_items, message.role)
    elseif type(content_items) == "table" then
      for _, item in ipairs(content_items) do
        if type(item) == "string" then
          add_text(message_content, item, message.role)
        elseif type(item) == "table" and item.type == "text" then
          add_text(message_content, item.text, message.role)
        elseif type(item) == "table" and item.type == "image" then
          local media_type = (item.source and item.source.media_type) or "image/png"
          local format = media_type:gsub("^image/", "")
          table.insert(message_content, {
            image = { format = format, source = { bytes = item.source and item.source.data } },
          })
        elseif type(item) == "table" and item.type == "tool_use" then
          table.insert(
            message_content,
            { toolUse = { toolUseId = item.id, name = item.name, input = item.input or {} } }
          )
        elseif type(item) == "table" and item.type == "tool_result" then
          local result_content
          if type(item.content) == "string" then
            result_content = { { text = item.content } }
          elseif type(item.content) == "table" then
            result_content = { { json = item.content } }
          else
            result_content = { { text = "" } }
          end
          table.insert(message_content, {
            toolResult = {
              toolUseId = item.tool_use_id,
              content = result_content,
              status = item.is_error and "error" or "success",
            },
          })
        end
        -- `thinking` / `redacted_thinking` blocks are intentionally dropped: Converse's
        -- reasoningContent pass-through isn't verified for Nemotron, and shipping a
        -- possibly-malformed block risks a request validation error.
      end
    end

    if #message_content > 0 then
      table.insert(messages, { role = self.role_map[message.role] or message.role, content = message_content })
    end
  end

  return messages
end

---@param self AvanteBedrockProviderFunctor
---@param tool AvanteLLMTool
---@return table Converse toolSpec
function M.transform_tool(self, tool)
  local input_schema_properties, required = Utils.llm_tool_param_fields_to_json_schema(tool.param.fields)
  return {
    toolSpec = {
      name = tool.name,
      description = tool.get_description and tool.get_description() or tool.description,
      inputSchema = {
        json = {
          type = "object",
          properties = input_schema_properties,
          required = required,
        },
      },
    },
  }
end

---@param provider AvanteBedrockProviderFunctor
---@param prompt_opts AvantePromptOptions
---@param request_body table extra_request_body from the provider config
---@return table Converse request body
function M.build_bedrock_payload(provider, prompt_opts, request_body)
  local P = require("avante.providers")
  local provider_conf, _ = P.parse_config(provider)
  local disable_tools = provider_conf.disable_tools or false

  local system = {}
  if prompt_opts.system_prompt and prompt_opts.system_prompt ~= "" then
    table.insert(system, { text = prompt_opts.system_prompt })
  end

  local messages = provider:parse_messages(prompt_opts)

  local tool_config = nil
  if not disable_tools and prompt_opts.tools and #prompt_opts.tools > 0 then
    local tools = {}
    for _, tool in ipairs(prompt_opts.tools) do
      table.insert(tools, provider:transform_tool(tool))
    end
    if #tools > 0 then tool_config = { tools = tools } end
  end

  request_body = request_body or {}
  local inference_config = { maxTokens = request_body.max_tokens or 4096 }
  if request_body.temperature ~= nil then inference_config.temperature = request_body.temperature end
  if request_body.top_p ~= nil then inference_config.topP = request_body.top_p end

  return {
    messages = messages,
    system = #system > 0 and system or nil,
    inferenceConfig = inference_config,
    toolConfig = tool_config,
  }
end

---@param self AvanteBedrockProviderFunctor
---@param data string raw Converse JSON response body
---@param _event_state any unused (no SSE event framing on the non-streaming endpoint)
---@param opts AvanteHandlerOptions
function M.parse_response_without_stream(self, data, _event_state, opts)
  local HistoryMessage = require("avante.history.message")

  local ok, jsn = pcall(vim.json.decode, data)
  if not ok then
    if opts.on_stop then opts.on_stop({ reason = "error", error = "Failed to parse Bedrock response: " .. data }) end
    return
  end

  -- Bedrock error responses (ValidationException, AccessDeniedException, ...) show up
  -- as a plain {"message": "..."} body here rather than the Converse {"output": ...} shape.
  if jsn.output == nil and jsn.message then
    if opts.on_stop then opts.on_stop({ reason = "error", error = jsn.message }) end
    return
  end

  local message = jsn.output and jsn.output.message
  local content_items = (message and message.content) or {}
  local new_messages = {}

  for _, block in ipairs(content_items) do
    if block.text then
      if opts.on_chunk then opts.on_chunk(block.text) end
      table.insert(new_messages, HistoryMessage:new("assistant", block.text, { state = "generated" }))
    elseif block.toolUse then
      table.insert(
        new_messages,
        HistoryMessage:new("assistant", {
          type = "tool_use",
          name = block.toolUse.name,
          id = block.toolUse.toolUseId,
          input = block.toolUse.input or {},
        }, { state = "generated" })
      )
    end
  end

  if opts.on_messages_add and #new_messages > 0 then opts.on_messages_add(new_messages) end

  local usage = nil
  if jsn.usage then usage = { prompt_tokens = jsn.usage.inputTokens, completion_tokens = jsn.usage.outputTokens } end

  if not opts.on_stop then return end

  if jsn.stopReason == "max_tokens" then
    opts.on_stop({ reason = "max_tokens", usage = usage })
  elseif jsn.stopReason == "tool_use" then
    opts.on_stop({ reason = "tool_use", usage = usage })
  elseif jsn.stopReason == "end_turn" or jsn.stopReason == "stop_sequence" then
    opts.on_stop({ reason = "complete", usage = usage })
  else
    opts.on_stop({ reason = "error", error = "Bedrock stopReason: " .. tostring(jsn.stopReason) })
  end
end

return M
