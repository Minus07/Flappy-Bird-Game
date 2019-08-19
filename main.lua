-- add the push library
push = require 'push'
--add the class library
Class = require 'class'
--add the Classes created
require 'Bird'
require 'Pipe'
require 'PipePair'
require 'StateMachine'
require 'Medal'
--add the different statese the game can enter
require 'states/BaseState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'
require 'states/CountdownState'
require 'states/PauseState'

-- define constants
WD_WIDTH = 1280
WD_HEIGHT = 720
VT_WIDTH = 512
VT_HEIGHT = 288
local BG_SPEED = 30 
local G_SPEED = 60
local BG_LOOP = 413
local background = love.graphics.newImage('background.png')
local backgroundScroll = 0
local ground = love.graphics.newImage('ground.png')
local groundScroll = 0
local bird = Bird()

local pipePairs = {}
local timer = 0

local lastY = -PIPE_HGT + math.random(80) + 20
local scrolling = true


function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')
    math.randomseed(os.time())
    love.window.setTitle('Happy Flap')
    smallFont = love.graphics.newFont('font.ttf',8)
    mediumeFont = love.graphics.newFont('flappy.ttf',16)
    flappyFont = love.graphics.newFont('flappy.ttf',28)
    hugeFont = love.graphics.newFont('flappy.ttf',56)
    love.graphics.setFont(flappyFont)
    sounds = {
        ['jump'] = love.audio.newSource('Jump.wav','static'),
        ['explosion'] = love.audio.newSource('Explosion.wav','static'),
        ['hurt'] = love.audio.newSource('hurt.wav','static'),
        ['score'] = love.audio.newSource('score.wav','static'),
        ['music'] = love.audio.newSource('Lavender.mp3','static')
    }
    sounds['music']:setLooping(true)
    sounds['music']:play()
    push:setupScreen(VT_WIDTH,VT_HEIGHT,WD_WIDTH,WD_HEIGHT, {
        vsync = true,
        resizable = true,
        fullscreen = false
    })
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['pause'] = function() return PauseState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end
function love.resize(width,height)
    push:resize(width,height)
end
function love.mousepressed(x,y,button)
    love.mouse.buttonsPressed[button] = true
end
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then 
        love.event.quit()
    end
end
-- function to determine was mouse has been 'pressed'
function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    if scrolling then 
        backgroundScroll = (backgroundScroll + BG_SPEED * dt)
            % BG_LOOP
        groundScroll = (groundScroll + G_SPEED * dt)
            % VT_WIDTH

        gStateMachine:update(dt)
        love.keyboard.keysPressed = {}
        love.mouse.buttonsPressed = {}
    end
end
function love.draw()
    push:start() 

    love.graphics.draw(background,-backgroundScroll,0)
    gStateMachine:render()

    love.graphics.draw(ground,-groundScroll,VT_HEIGHT-16)
    push:finish()
end