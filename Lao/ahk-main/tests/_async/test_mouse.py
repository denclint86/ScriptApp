import asyncio
import os
import subprocess
import sys
import time
from unittest import IsolatedAsyncioTestCase

from ahk import AsyncAHK
from ahk import AsyncWindow

async_sleep = asyncio.sleep  # unasync: remove

sleep = time.sleep


class TestMouseAsync(IsolatedAsyncioTestCase):
    win: AsyncWindow

    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK()

    async def asyncTearDown(self) -> None:
        try:
            self.ahk._transport._proc.kill()
        except:
            pass
        time.sleep(0.2)

    async def test_mouse_position(self) -> None:
        pos = await self.ahk.get_mouse_position()
        assert isinstance(pos, tuple)
        assert len(pos) == 2
        x, y = pos
        assert isinstance(x, int)
        assert isinstance(y, int)

    async def test_mouse_move(self) -> None:
        await self.ahk.mouse_move(x=100, y=100)
        pos = await self.ahk.get_mouse_position()
        assert pos == (100, 100)
        await self.ahk.mouse_move(x=200, y=200)
        pos2 = await self.ahk.get_mouse_position()
        assert pos2 == (200, 200)

    async def test_mouse_move_rel(self):
        await self.ahk.mouse_move(x=100, y=100)
        await async_sleep(0.5)
        pos = await self.ahk.get_mouse_position()
        assert pos == (100, 100)
        await self.ahk.mouse_move(x=10, y=10, relative=True)
        await async_sleep(0.5)
        pos2 = await self.ahk.get_mouse_position()
        x1, y1 = pos
        x2, y2 = pos2
        assert abs(x1 - x2) == 10
        assert abs(y1 - y2) == 10

    async def test_mouse_move_nonblocking(self):
        await self.ahk.mouse_move(100, 100)
        res = await self.ahk.mouse_move(500, 500, speed=10, send_mode='Event', blocking=False)
        current_pos = await self.ahk.get_mouse_position()
        await async_sleep(0.1)
        pos = await self.ahk.get_mouse_position()
        assert pos != current_pos
        assert pos != (500, 500)
        await res.result()

    async def test_mouse_drag(self):
        await self.ahk.mouse_move(x=100, y=100)
        pos = await self.ahk.get_mouse_position()
        assert pos == (100, 100)
        await self.ahk.mouse_drag(x=200, y=200)
        pos2 = await self.ahk.get_mouse_position()
        assert pos2 == (200, 200)

    async def test_mouse_drag_relative(self):
        await self.ahk.mouse_move(x=100, y=100)
        await async_sleep(0.5)
        pos = await self.ahk.get_mouse_position()
        assert pos == (100, 100)
        await self.ahk.mouse_drag(x=10, y=10, relative=True, button=1)
        await async_sleep(0.5)
        pos2 = await self.ahk.get_mouse_position()
        x1, y1 = pos
        x2, y2 = pos2
        assert abs(x1 - x2) == 10
        assert abs(y1 - y2) == 10

    async def test_coord_mode(self):
        await self.ahk.set_coord_mode(target='Mouse', relative_to='Client')
        res = await self.ahk.get_coord_mode(target='Mouse')
        assert res == 'Client'

    async def test_send_mode(self):
        await self.ahk.set_send_mode('InputThenPlay')
        res = await self.ahk.get_send_mode()
        assert res == 'InputThenPlay'


class TestMouseAsyncV2(TestMouseAsync):
    async def asyncSetUp(self) -> None:
        self.ahk = AsyncAHK(version='v2')
