module MsgPackRpcClientSockPool

#export SockPool

include("const.jl")

type SockPool
  pool :: Array
end

function new()
  SockPool(Union(Base.TcpSocket, Nothing)[])
end

function show(self::SockPool)
  println(self.pool)
  nothing
end

function is_empty(self::SockPool)
  if length(self.pool) != 0
    return false
  else
    return true
  end
end

function reject!(self::SockPool)
end

function push(self::SockPool, sock::Base.TcpSocket)
  push!(self.pool, sock)
  self
end

function pop(self::SockPool; or_create = true, port::Int = DEFAULT_PORT_NUMBER)
  try
    sock = pop!(self.pool)
    return sock
  catch
    # TODO: Add error handling
  end
  if or_create == true
    try
      return connect(port)
    catch
      # TODO: Add error handling
    end
  end
  nothing
end

function add_port(self::SockPool, port::Int = DEFAULT_PORT_NUMBER)
  sock = connect(port)
  push!(self.pool, sock)
  self
end

function add_port_range(self::SockPool, range::UnitRange)
  for x = range
    sock = connect(x)
    push!(self.pool, sock)
  end
  self
end

function delete(self::SockPool, sock::Base.TcpSocket)
  i = 1
  for x in self.pool
    if x == sock
      if isopen(self.pool[i])
        close(self.pool[i])
      end
      self.pool[i] = nothing
    end
    i += 1
  end
  self
end

function destroy(self::SockPool)
  try
    if is_empty(self)
      return true
    end
    for x in self.pool
      if x == nothing
        continue
      end
      if isopen(x)
        close(x)
      end
    end
  catch
    return false
  end
  true
end

end # module MsgPackRpcClientSockPool

