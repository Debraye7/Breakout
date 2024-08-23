--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    self.recoverPoints = 5000

    --! Cambios
    self.numberBalls = 1
    self.balls = { params.ball }

    self.timer = 0
    self.powerBalls = Power(1)
    self.powerKey = Power(2)

    self.counterPaddle = 0
    self.counterRecover = 0

    self.lock = Lock(VIRTUAL_WIDTH/2 - 16, 16)
    self.key = false
end

function PlayState:ballColisionPaddle(ball)
  if ball.inPlay == true and ball:collides(self.paddle) then
      ball.y = self.paddle.y - 8
      ball.dy = -ball.dy

      if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
          ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

      elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
          ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
      end

      gSounds['paddle-hit']:play()
  end
end

function PlayState:ballColisionBrick(brick, ball)
  if ball.inPlay == true and ball:collides(brick) then
      local points = brick.tier * 200 + brick.color * 25
      self.score = self.score + points

      if self.counterPaddle + points > 1000 then
          self.paddle:resize(true)
          self.counterPaddle = (self.counterPaddle + points) - 1000
      else
          self.counterPaddle = self.counterPaddle + points
      end


      brick:hit(self.key)

      if self.counterRecover > self.recoverPoints then

          self.health = math.min(3, self.health + 1)

          self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

          gSounds['recover']:play()

          self.counterRecover = (self.counterRecover + points) - self.recoverPoints
      else
          self.counterRecover = self.counterRecover + points
      end

      if self:checkVictory() then
          gSounds['victory']:play()

          gStateMachine:change('victory', {
              level = self.level,
              paddle = self.paddle,
              health = self.health,
              score = self.score,
              highScores = self.highScores,
              ball = ball,
              recoverPoints = self.recoverPoints
          })
      end

      if ball.x + 2 < brick.x and ball.dx > 0 then

          ball.dx = -ball.dx
          ball.x = brick.x - 8

      elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

          ball.dx = -ball.dx
          ball.x = brick.x + 32

      elseif ball.y < brick.y then

          ball.dy = -ball.dy
          ball.y = brick.y - 8

      else

          ball.dy = -ball.dy
          ball.y = brick.y + 16
      end

      if math.abs(ball.dy) < 150 then
          ball.dy = ball.dy * 1.02
      end

  end
end

function PlayState:ballLose(ball)
    if ball.inPlay == true and ball.y >= VIRTUAL_HEIGHT then
        ball:remove()
        self.numberBalls = self.numberBalls - 1
    end
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    if self.numberBalls == 0 then
      self.paddle:resize(false)
      self.health = self.health - 1
      gSounds['hurt']:play()

      if self.health == 0 then
          gStateMachine:change('game-over', {
              score = self.score,
              highScores = self.highScores
          })
      else
          gStateMachine:change('serve', {
              paddle = self.paddle,
              bricks = self.bricks,
              health = self.health,
              score = self.score,
              highScores = self.highScores,
              level = self.level,
              recoverPoints = self.recoverPoints
          })
      end
    end

    if self.numberBalls == 1 then
      self.powerBalls.active = false
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    for b, ball in pairs(self.balls) do
      ball:update(dt)
    end

    --! Cambios 
    for b, ball in pairs(self.balls) do
      self:ballColisionPaddle(ball)
    end
    for k, brick in pairs(self.bricks) do
        if brick.inPlay  then
            for b, ball in pairs(self.balls) do
              self:ballColisionBrick(brick, ball)
            end
        end
    end

    if self.lock.inPlay  then
      for b, ball in pairs(self.balls) do
        self:ballColisionBrick(self.lock, ball)
      end
    end

    for b, ball in pairs(self.balls) do
      self:ballLose(ball)
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.powerBalls:update(dt)

    if self.powerBalls:collides(self.paddle) then
        self.powerBalls.active = true
        self.powerBalls.x = math.random(0, VIRTUAL_WIDTH-16)
        self.powerBalls.y = -16
        self.powerBalls.dy = 0
        self.numberBalls = self.numberBalls + 2
        newBall1 = Ball(math.random(7))
        newBall1.inPlay = true
        newBall1.dx = math.random(-200, 200)
        newBall1.dy = math.random(-50, -60)
        newBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
        newBall1.y = self.paddle.y - 8
        newBall2 = Ball(math.random(7))
        newBall2.inPlay = true
        newBall2.dx = math.random(-200, 200)
        newBall2.dy = math.random(-50, -60)
        newBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
        newBall2.y = self.paddle.y - 8
        table.insert(self.balls, newBall1)
        table.insert(self.balls, newBall2)
    end

    if self.level % 2 == 0 then
      self.powerKey:update(dt)
    end

    if self.powerKey:collides(self.paddle) then
      self.lock.tier = 5
      self.lock.color = 20
      self.powerKey.active = true
      self.powerKey.x = math.random(0, VIRTUAL_WIDTH-16)
      self.powerKey.y = -16
      self.powerKey.dy = 0
      self.key = true
    end

end

function PlayState:render()

    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    for b, ball in pairs(self.balls) do
      ball:render()
    end
    self.powerBalls:render()
    self.powerKey:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end

    if self.powerBalls.active == true then
      love.graphics.draw(gTextures['main'], gFrames['powers'][1], 5, 15)
    end
    if self.powerKey.active == true then
        love.graphics.draw(gTextures['main'], gFrames['powers'][2], 5, 35)
    end

    if self.level % 2 == 0 then
        self.lock:render()
    else
        self.lock.inPlay = false
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end
    if self.lock.inPlay then
        return false
    end

    return true
end