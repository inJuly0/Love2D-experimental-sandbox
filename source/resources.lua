local Resources = {Texture = {}}

function Resources.load()
    -- textures and images
    love.graphics.setDefaultFilter('nearest', 'nearest')
    Resources.Texture.Player = love.graphics.newImage('assets/img/suit_guy.png')
end

return Resources
