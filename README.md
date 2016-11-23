# WallBall

-- Current Status - Alpha

-- Tested On : Terasic DE1-SOC (Altera Cyclone V FPGA)

A basic Pong-like game. 

Player moves the paddle in the xy plane using four buttons. Ball movement and collisions are automatically handled.
Collision zones are: left wall, right wall, ceiling, top of paddle.

Every time the player hits the ball with the top of the paddle, a point is scored.

When the ball touches the floor, the ball stops moving.

There are asynchronous pause and reset controls.
