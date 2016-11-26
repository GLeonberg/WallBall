# WallBall

- Current Status - Beta

- Tested On : Terasic DE1-SOC (Altera Cyclone V FPGA)

- Current Problems:
 * Minor Glitch
   * if paddle moves towards ball leading into collision (ie opposite direction of ball motion), ball phases through paddle
                    
A basic Pong-like game. 

Player moves the paddle in the xy plane using four buttons. 
Ball movement and collisions are automatically handled.
Collision zones are: left wall, right wall, ceiling, top of paddle, side of paddle.

Every time the ball touches the ceiling, a point is scored.

When the ball touches the floor, the ball stops moving.

Single pixel blue border for screen position adjustment

There are asynchronous pause and reset controls.
