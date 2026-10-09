if filereadable($KIT_TEST_PLUGIN . '/plugin/tidal.vim')
  execute 'source ' . fnameescape($KIT_TEST_ROOT . '/editors/vim-tidal.vim')
  execute 'source ' . fnameescape($KIT_TEST_PLUGIN . '/plugin/tidal.vim')
  TidalSend1 import Control.Concurrent (threadDelay)
  TidalSend1 d1 $ sound "bd*4"
  TidalSend1 threadDelay 4000000
  TidalHush
  TidalSend1 threadDelay 3000000
  TidalSend1 putStrLn "KIT_EDITOR_FINISHED"
else
  execute 'set rtp+=' . fnameescape($KIT_TEST_PLUGIN)
  lua dofile(vim.env.KIT_TEST_ROOT .. '/editors/tidal.nvim.lua')
  TidalLaunch
  lua require('tidal.api').send('import Control.Concurrent (threadDelay)')
  lua require('tidal.api').send('d1 $ sound "bd*4"')
  lua require('tidal.api').send('threadDelay 4000000')
  lua require('tidal.api').send('hush')
  lua require('tidal.api').send('threadDelay 3000000')
  lua require('tidal.api').send('putStrLn "KIT_EDITOR_FINISHED"')
endif
lua << EOF
local finished = vim.wait(90000, function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.b[b].terminal_job_id then
      for _, line in ipairs(vim.api.nvim_buf_get_lines(b, 0, -1, false)) do
        if line:match('^KIT_EDITOR_FINISHED%s*$') or line:match('^tidal> KIT_EDITOR_FINISHED%s*$') then
          return true
        end
      end
    end
  end
  return false
end, 100)
if not finished then
  vim.api.nvim_err_writeln('Timed out waiting for the editor Tidal session')
  vim.cmd('cquit 1')
end
EOF
lua for _,b in ipairs(vim.api.nvim_list_bufs()) do local j=vim.b[b].terminal_job_id; if j then vim.fn.chansend(j, ':quit\n') end end
sleep 1
qa!
