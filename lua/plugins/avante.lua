-- avante.nvim configured for NVIDIA Nemotron Super 3 120B via AWS Bedrock in
-- GovCloud West (us-gov-west-1), authenticated through an AWS SSO profile
-- (`aws sso login --profile <profile>`) rather than static keys.
--
-- Prerequisites (not covered by lazy.nvim -- see chat for details):
--   - AWS CLI v2 installed and on PATH (bedrock.lua shells out to
--     `aws configure export-credentials` to turn the SSO profile into short-lived
--     sigv4 credentials).
--   - curl >= 8.10.0 (curl's --aws-sigv4 flag is what actually signs the request;
--     older curl silently lacks proper sigv4 support).
--   - A `[profile <name>]` block in ~/.aws/config with sso_session/sso_account_id/
--     sso_role_name, matching AWS_PROFILE below.
--
-- The `nvidia.nemotron-super-3-120b` model id has no built-in avante handler (only
-- Claude/Anthropic models on Bedrock ship with one), so this config pairs with a
-- custom handler at lua/avante/providers/bedrock/nvidia/nemotron-super-3-120b.lua
-- that speaks Bedrock's Converse API instead of the Claude-only invoke_model format.

return {
  'yetone/avante.nvim',
  build = 'make',
  event = 'VeryLazy',
  version = false, -- avante's own recommendation: track main, not a tagged release
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
  },
  opts = {
    provider = 'bedrock',
    providers = {
      bedrock = {
        model = 'nvidia.nemotron-super-3-120b',
        aws_region = 'us-gov-west-1',
        aws_profile = 'bedrock-gov', -- replace with your actual `aws sso login` profile name
        -- Explicit endpoint: points at the non-streaming Converse API (see the model
        -- handler file for why streaming isn't wired up), for this model + region.
        endpoint = 'https://bedrock-runtime.us-gov-west-1.amazonaws.com/model/nvidia.nemotron-super-3-120b/converse',
        timeout = 60000,
        extra_request_body = {
          max_tokens = 8192,
          temperature = 0.7,
        },
      },
    },
  },
}
