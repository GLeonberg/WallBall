# WallBall

- Current Status - Alpha

- Tested On : Terasic DE1-SOC (Altera Cyclone V FPGA)

- Current Problems:
 * Ball "sinks" into collision objects (timing issue between processes in ball module?)
 * Left Wall SW Collision and Right Wall SE Collision glitched (because of wall sinking)
 * Paddle side collisions not registering
                    
A basic Pong-like game. 

Player moves the paddle in the xy plane using four buttons. 
Ball movement and collisions are automatically handled.
Collision zones are: left wall, right wall, ceiling, top of paddle.

Every time the player hits the ball with the top of the paddle, a point is scored.

When the ball touches the floor, the ball stops moving.

There are asynchronous pause and reset controls.
