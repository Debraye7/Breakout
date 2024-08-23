Power = Class{}

function Power:init(skin)
    self.x = math.random(20, VIRTUAL_WIDTH - 20)

    self.y = -16

    self.dy = 0

    self.width = 16
    self.height = 16

    self.active = false
    self.skin = skin
    self.timer = 0
    self.seconds = math.random(10, 20)
end

function Power:reset()
  self.x = math.random(20, VIRTUAL_WIDTH - 20)
  self.y = -16
  self.dy = 0
  self.active = false
  self.seconds = math.random(10, 20)
  self.timer = 0
end

function Power:collides(target)

  if self.x > target.x + target.width or target.x > self.x + self.width then
      return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
      return false
  end

  return true
end

function Power:update(dt)
    if self.active == false then
        self.timer = self.timer + dt
        if self.timer > self.seconds then
            self.y = self.y + self.dy * dt
            self.dy = POWER_SPEED
        end
    else
        self.timer = 0
        self.seconds = math.random(10, 20)
    end
    if self.y > VIRTUAL_HEIGHT then
      self:reset()
    end
end

function Power:render()
    if self.active == false then
        love.graphics.draw(gTextures['main'], gFrames['powers'][self.skin], self.x, self.y)
    end
end