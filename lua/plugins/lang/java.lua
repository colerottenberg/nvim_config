-- Java: nvim-java sets up and drives jdtls. Must run before jdtls attaches,
-- so it loads on ft=java and enables the server itself.

return {
  'nvim-java/nvim-java',
  ft = 'java',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'mfussenegger/nvim-dap',
    'JavaHello/spring-boot.nvim',
  },
  config = function()
    require('java').setup()
    vim.lsp.enable('jdtls')
  end,
}
