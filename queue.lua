

local Queue = {}
function Queue:new()
  local obj = {first = 0, last = -1}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

function Queue:push(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function Queue:pop()
  local first = self.first
  if first > self.last then error("queue is empty") end
  local value = self[first]
  self[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return value
end

function Queue:is_empty()
  return self.first > self.last
end

-- Example usage
--[[

local q = Queue:new()
q:push(1)
q:push(2)
q:push(3)

while not q:is_empty() do
  print(q:pop())
end

]]


return Queue