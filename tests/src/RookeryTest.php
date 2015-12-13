<?php

class RookeryTest extends TestCase
{
    public function testRun()
    {
        $rook = new \Rookery\Rookery();
        $this->assertEquals('run', $rook->run());
    }
}