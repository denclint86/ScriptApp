import pathlib
import subprocess
import tempfile
import time
import unittest.mock

from ahk import AsyncAHK
from ahk import AsyncWindow


class TestScripts(unittest.IsolatedAsyncioTestCase):
    win: AsyncWindow

    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK()

    async def asyncTearDown(self) -> None:
        try:
            self.ahk._transport._proc.kill()
        except:
            pass
        subprocess.run(['TASKKILL', '/F', '/IM', 'notepad.exe'], capture_output=True)
        time.sleep(0.2)

    async def test_script_missing_makes_tempfile(self):
        with unittest.mock.patch('os.path.exists', new=unittest.mock.Mock(return_value=False)):
            pos = await self.ahk.get_mouse_position()
            path = pathlib.Path(self.ahk._transport._proc.runargs[-1])
            filename = path.name
            assert filename.startswith('python-ahk-')
            assert filename.endswith('.ahk')
            assert isinstance(pos, tuple) and isinstance(pos[0], int)

    async def test_run_script_text(self):
        assert await self.ahk.win_get(title='Untitled - Notepad') is None
        script = 'FileAppend, foobar, *, UTF-8'
        result = await self.ahk.run_script(script)
        assert result == 'foobar'

    async def test_run_script_file(self):
        assert await self.ahk.win_get(title='Untitled - Notepad') is None
        with tempfile.NamedTemporaryFile(suffix='.ahk', mode='w', delete=False) as f:
            f.write('FileAppend, foobar, *, UTF-8')
        res = await self.ahk.run_script(f.name)
        assert res == 'foobar'

    async def test_run_script_file_unicode(self):
        assert await self.ahk.win_get(title='Untitled - Notepad') is None
        subprocess.Popen('Notepad')
        await self.ahk.win_wait(title='Untitled - Notepad', timeout=3)
        with tempfile.NamedTemporaryFile(suffix='.ahk', mode='w', delete=False, encoding='utf-8') as f:
            f.write('WinActivate, "Untitled - Notepad"\nSend א ב ג ד ה ו ז ח ט י ך כ ל ם מ ן נ ס ע ף פ ץ צ ק ר ש ת װ ױ')
        await self.ahk.run_script(f.name)
        notepad = await self.ahk.win_wait(title='*Untitled - Notepad', timeout=3)
        assert notepad is not None
        text = await notepad.get_text()
        assert 'א ב ג ד ה ו ז ח ט י ך כ ל ם מ ן נ ס ע ף פ ץ צ ק ר ש ת װ ױ' in text

    async def test_run_script_nonblocking(self):
        script = 'FileAppend, foo, *, UTF-8'
        fut = await self.ahk.run_script(script, blocking=False)
        assert await fut.result() == 'foo'


class TestScriptsV2(TestScripts):
    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK(version='v2')

    async def test_run_script_text(self):
        assert not await self.ahk.win_exists(title='Untitled - Notepad')
        script = 'stdout := FileOpen("*", "w", "UTF-8")\nstdout.Write("foobar")\nstdout.Read(0)'
        result = await self.ahk.run_script(script)
        assert result == 'foobar'

    async def test_run_script_file(self):
        assert not await self.ahk.win_exists(title='Untitled - Notepad')
        with tempfile.NamedTemporaryFile(suffix='.ahk', mode='w', delete=False) as f:
            f.write('stdout := FileOpen("*", "w", "UTF-8")\nstdout.Write("foobar")\nstdout.Read(0)')
        res = await self.ahk.run_script(f.name)
        assert res == 'foobar'

    async def test_run_script_file_unicode(self):
        assert not await self.ahk.win_exists(title='Untitled - Notepad')
        subprocess.Popen('Notepad')
        await self.ahk.win_wait(title='Untitled - Notepad', timeout=3)
        with tempfile.NamedTemporaryFile(suffix='.ahk', mode='w', delete=False, encoding='utf-8') as f:
            f.write(
                'WinActivate "Untitled - Notepad"\nSend "א ב ג ד ה ו ז ח ט י ך כ ל ם מ ן נ ס ע ף פ ץ צ ק ר ש ת װ ױ"'
            )
        await self.ahk.run_script(f.name)
        notepad = await self.ahk.win_wait(title='*Untitled - Notepad', timeout=3)
        assert notepad is not None
        text = await notepad.get_text()
        assert 'א ב ג ד ה ו ז ח ט י ך כ ל ם מ ן נ ס ע ף פ ץ צ ק ר ש ת װ ױ' in text

    async def test_run_script_nonblocking(self):
        script = 'stdout := FileOpen("*", "w", "UTF-8")\nstdout.Write("foo")\nstdout.Read(0)'
        fut = await self.ahk.run_script(script, blocking=False)
        assert await fut.result() == 'foo'
