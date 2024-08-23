Lock = Class{}

-- love.graphics.draw(gTextures['main'], gFrames['lock'], VIRTUAL_WIDTH/2, VIRTUAL_HEIGHT/2)

paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Lock:init(x, y)
    -- used for coloring and score calculation
    self.tier = 0
    self.color = 0
    
    self.x = x
    self.y = y
    self.width = 33
    self.height = 16
    
    -- used to determine whether this brick should be rendered
    self.inPlay = true

    -- particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- various behavior-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural than uniform
    self.psystem:setEmissionArea('normal', 10, 10)
end

--[[
    Triggers a hit on the brick, taking it out of play if at 0 health or
    changing its color otherwise.
]]

function Lock:hit(key)
    if key == true then
        self.inPlay = false;
        self.x = 0
        self.y = 0
    end
end

function Lock:update(dt)
    self.psystem:update(dt)
end

function Lock:render()
    if self.inPlay then
        love.graphics.draw(gTextures['main'], gFrames['lock'], self.x, self.y)
    end
end

--[[
    Need a separate render function for our particles so it can be called after all bricks are drawn;
    otherwise, some bricks would render over other bricks' particle systems.
]]
function Lock:renderParticles()
    if self.inPlay then
        love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
    end
end