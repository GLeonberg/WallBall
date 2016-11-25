# WallBall

- Current Status - Alpha

- Tested On : Terasic DE1-SOC (Altera Cyclone V FPGA)

- Current Problems:
 * Ball "sinks" into paddle (because of ball wait for current padddle position?)
 * Left Wall SW Collision and Right Wall SE Collision glitched
                    
A basic Pong-like game. 

Player moves the paddle in the xy plane using four buttons. 
Ball movement and collisions are automatically handled.
Collision zones are: left wall, right wall, ceiling, top of paddle, side of paddle.

Every time the ball touches the ceiling, a point is scored.

When the ball touches the floor, the ball stops moving.

Single pixel blue border for screen position adjustment

There are asynchronous pause and reset controls.
