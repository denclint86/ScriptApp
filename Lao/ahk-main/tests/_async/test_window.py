import asyncio
import os
import subprocess
import sys
import time
import tracemalloc
from unittest import IsolatedAsyncioTestCase

import pytest

import ahk

tracemalloc.start()

from ahk import AsyncAHK
from ahk import AsyncWindow


class TestWindowAsync(IsolatedAsyncioTestCase):
    win: AsyncWindow

    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK()
        self.p = subprocess.Popen('notepad')
        time.sleep(1)
        self.win = await self.ahk.win_get(title='Untitled - Notepad')
        self.assertIsNotNone(self.win)

    async def asyncTearDown(self) -> None:
        try:
            self.p.kill()
        except:
            pass
        self.p.communicate()
        self.ahk._transport._proc.kill()
        subprocess.run(['TASKKILL', '/F', '/IM', 'notepad.exe'], capture_output=True)
        time.sleep(0.2)

    async def test_exists(self):
        self.assertTrue(await self.ahk.win_exists(title='Untitled - Notepad'))
        self.assertTrue(await self.win.exists())

    async def test_close(self):
        await self.win.close()
        time.sleep(0.2)
        self.assertFalse(await self.win.exists())

    async def test_win_get_returns_none_nonexistent(self):
        win = await self.ahk.win_get(title='DOES NOT EXIST')
        assert win is None

    async def test_exists_nonexistent_is_false(self):
        assert await self.ahk.win_exists(title='DOES NOT EXIST') is False

    async def test_win_pid(self):
        pid = await self.win.get_pid()
        assert isinstance(pid, int)

    async def test_win_process_name(self):
        process_name = await self.win.get_process_name()
        assert process_name == 'notepad.exe'

    async def test_win_process_path(self):
        process_path = await self.win.get_process_path()
        assert 'notepad.exe' in process_path

    async def test_win_minmax(self):
        minmax = await self.win.get_minmax()
        assert minmax == 0

    async def test_win_set_always_on_top(self):
        assert await self.win.is_always_on_top() is False
        await self.win.set_always_on_top('On')
        assert await self.win.is_always_on_top() is True

    async def test_window_list_controls(self):
        controls = await self.win.list_controls()
        assert isinstance(controls, list)
        assert len(controls) == 2

    async def test_set_detect_hidden_windows(self):
        non_hidden = await self.ahk.list_windows()
        await self.ahk.set_detect_hidden_windows(True)
        all_windows = await self.ahk.list_windows()
        assert len(all_windows) > len(non_hidden)

    async def test_detect_hidden_windows_false_works(self):
        await self.ahk.set_detect_hidden_windows(True)
        all_windows = await self.ahk.list_windows()
        await self.ahk.set_detect_hidden_windows(False)
        non_hidden = await self.ahk.list_windows()
        assert len(non_hidden) < len(all_windows)

    async def test_list_windows_hidden_false(self):
        non_hidden = await self.ahk.list_windows()
        all_windows = await self.ahk.list_windows(detect_hidden_windows=False)
        assert len(non_hidden) == len(all_windows)

    async def test_list_windows_hidden(self):
        non_hidden = await self.ahk.list_windows()
        all_windows = await self.ahk.list_windows(detect_hidden_windows=True)
        assert len(all_windows) > len(non_hidden)

    async def test_win_get_title(self):
        title = await self.win.get_title()
        assert title == 'Untitled - Notepad'

    async def test_win_get_idlast(self):
        await self.ahk.win_set_bottom(title='Untitled - Notepad')
        w = await self.ahk.win_get_idlast(title='Untitled - Notepad')
        assert w == self.win

    async def test_win_get_count(self):
        count = await self.ahk.win_get_count(title='Untitled - Notepad')
        assert count == 1

    # async def test_win_get_count_hidden(self):
    #     count = await self.ahk.win_get_count()
    #     all_count = await self.ahk.win_get_count(detect_hidden_windows=True)
    #     assert all_count > count

    async def test_win_exists(self):
        assert await self.win.exists()
        await self.win.close()
        assert not await self.win.exists()

    async def test_win_set_title(self):
        await self.win.set_title(new_title='Foo')
        assert await self.win.get_title() == 'Foo'

    async def test_control_send_window(self):
        await self.win.send('hello world', control='Edit1')
        text = await self.win.get_text()
        assert 'hello world' in text

    async def test_send_literal_comma(self):
        await self.win.send('hello, world', control='Edit1')
        text = await self.win.get_text()
        assert 'hello, world' in text

    async def test_type_escape(self):
        await self.win.activate()
        await self.ahk.type('hello, world!')
        time.sleep(0.2)
        text = await self.win.get_text()
        assert '!' in text

    async def test_send_input_manual_escapes(self):
        await self.win.activate()
        await self.ahk.send_input('Hello{Enter}World{!}')
        time.sleep(0.4)
        text = await self.win.get_text()
        assert 'Hello\r\nWorld!' in text

    async def test_send_literal_tilde_n(self):
        expected_text = '```nim\nimport std/strformat\n```'
        await self.win.send(expected_text, control='Edit1')
        text = await self.win.get_text()
        assert '```nim' in text
        assert '\nimport std/strformat' in text
        assert '\n```' in text

    async def test_set_title_match_mode_and_speed(self):
        await self.ahk.set_title_match_mode(('RegEx', 'Slow'))
        speed = await self.ahk.get_title_match_speed()
        mode = await self.ahk.get_title_match_mode()
        assert mode == 'RegEx'
        assert speed == 'Slow'

    async def test_set_title_match_mode(self):
        await self.ahk.set_title_match_mode('RegEx')
        mode = await self.ahk.get_title_match_mode()
        assert mode == 'RegEx'

    async def test_set_title_match_speed(self):
        await self.ahk.set_title_match_mode('Slow')
        speed = await self.ahk.get_title_match_speed()
        assert speed == 'Slow'

    async def test_control_send_from_control(self):
        controls = await self.win.list_controls()
        edit_control = controls[0]
        await edit_control.send('hello world')
        text = await self.win.get_text()
        assert 'hello world' in text

    async def test_control_position(self):
        controls = await self.win.list_controls()
        edit_control = controls[0]
        pos = await edit_control.get_position()
        assert pos

    async def test_win_position(self):
        pos = await self.win.get_position()
        assert pos

    async def test_win_activate(self):
        await self.win.activate()
        w = await self.ahk.get_active_window()
        assert w == self.win

    async def test_win_get_class(self):
        assert await self.win.get_class() == 'Notepad'

    async def test_win_move(self):
        await self.win.move(100, 100, width=300, height=300)
        await self.win.move(200, 200, width=400, height=500)
        time.sleep(1)
        assert await self.win.get_position() == (200, 200, 400, 500)

    async def test_win_is_active(self):
        await self.win.activate()
        assert await self.win.is_active() is True


class TestWindowAsyncV2(TestWindowAsync):
    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK(version='v2')
        self.p = subprocess.Popen('notepad')
        time.sleep(1)
        self.win = await self.ahk.win_get(title='Untitled - Notepad')
        self.assertIsNotNone(self.win)

    async def test_win_get_returns_none_nonexistent(self):
        with pytest.raises(ahk.message.AHKExecutionException):
            win = await self.ahk.win_get(title='DOES NOT EXIST')
