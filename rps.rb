#!/usr/bin/env ruby

# Universidad Simón Bolívar
# Departamento de Computación y Tecnología de la Información
# CI3661 - Laboratorio de Lenguajes de Programación I
# Trimestre Enero - Marzo 2016.
# 
# Tarea Ruby
# Juego ”Piedra, Papel o Tijeras”
#  
# Autores: Gabriel Iglesias 11-10476.
#          Oscar Guillen    11-11264.

# Clase abstracta para movimientos.
class Movement
	def to_s 
		self.class.name
	end
end

# Clase que representa la jugada piedra. 
class Rock < Movement
	def score(m)
		m.compareRock
	end

	def compareRock
		return [0,0]
	end

	def comparePaper
		return [0,1]
	end

	def compareScissors
		return [1,0]
	end
end

# Clase que representa la jugada papel.
class Paper < Movement
	def score(m)
		m.comparePaper
	end

	def compareRock
		return [0,1]
	end

	def comparePaper
		return [0,0]
	end

	def compareScissors
		return [0,1]
	end
end

# Clase que representa la jugada tijeras.
class Scissors < Movement
	def score(m)
		m.compareScissors
	end

	def compareRock
		return [0,1]
	end

	def comparePaper
		return [1,0]
	end

	def compareScissors
		return [0,0]
	end
end

# Clase abstracta para estrategias.
class Strategy
	
	SEED = 42
	PRNG = Random.new(SEED)

	def to_s
		self.class.name	
	end

	def next(mov = nil)
		raise RunTimeError, 
			  "No existe siguiente movimiento para una estrategia abstracta"
	end

	def reset
		raise RunTimeError,
			  "No se puede hacer reset de esta estrategia"
	end
end

# Estrategia en la que cada jugada de la lista de jugadas posibles tiene 
# la misma posibilidad de ser elegida
class Uniform < Strategy

	attr_reader :list

	def initialize(list)
		@list = list.uniq
		
		if @list.empty? 
			raise ArgumentError, "Error: lista de movimientos vacia"

		# elsif (@list - [:Rock,:Scissors,:Paper]).empty?
		# 	raise ArgumentError, 
		# 		  "Error: lista de movimientos contiene movimientos no validos"
		end

	end

	def next(mov = nil)
		index = PRNG.rand(@list.length)
		
		case @list[index]
			when :Rock
				return Rock.new
			when :Scissors
				return Scissors.new
			when :Paper
				return Paper.new
		end	
	
	end

	def to_s
		puts "Estrategia #{self.class.name}. Jugadas Posibles: " + @list.to_s
	end

	def reset
	end
end

# Estrategia en las jugadas de la lista de jugadas posibles tienen 
# distintas probabilidades de ser elegidas.
class Biased < Strategy

	attr_reader :hash, :pr

	def initialize(hash)
		@hash = hash

		if @hash.empty? 
			raise ArgumentError, "hash de movimientos vacio"

		# elsif (@hash.keys - [:Rock,:Scissors,:Paper]).empty?
		# 	raise ArgumentError, 
		# 		  "Error: hash de movimientos contiene movimientos no validos"
		end
	
		@pr = @hash.values.inject(:+)
	end

	def next(mov = nil)
		random = PRNG.rand(@pr) 
		
		acc = 0
		@hash.each {|k,v| 
			if acc + v > random
				
				case k
					when :Rock
						return Rock.new
					when :Scissors
				 		return Scissors.new
				 	when :Paper
				 		return Paper.new
				 end

			else
				acc += v
			end
		}
	
	end

	def to_s
		puts "Estrategia #{self.class.name}. Jugadas Posibles: " + @hash.to_s
	end

	def reset
	end
end

# Estrategia en la que se juega lo mismo que jugó el oponente en el 
# turno anterior.
class Mirror < Strategy

	attr_reader :initial_mov      # Movimiento inicial.
	attr_accessor :opponent_mov   # Movimiento del oponente.

	def initialize(mov)
		@initial_mov = @opponent_mov = mov
	end

	def next(mov)
		@opponent_mov = mov
		return @opponent_mov
	end

	def reset
		@opponent_mov = @initial_mov
	end
end

# Estrategia en la que la jugada depende de las jugadas anteriores hechas 
# por el oponente.
class Smart < Strategy

	attr_accessor :p, :r, :s
	
	def initialize
		@p = 0
		@r = 0
		@s = 0
	end

	def next(mov)
		random = PRNG.rand(p+r+s-1)

		# Decide cual sera la siguiente jugada
		# result = case random
		# 	when 0...p       then Scissors.new
		# 	when p...p+r     then Paper.new
		# 	when p+r...p+r+s then Rock.new
		# end

		# # Aumenta la frecuencia de la jugada recien hecha por el oponente.
		# case random
		# 	when 0...p       then @s += 1
		# 	when p...p+r     then @p += 1
		# 	when p+r...P+r+s then @r += 1
		# end

		case random
			when 0...p
				@s += 1
				return Scissors.new
			when p...p+r
				@p += 1
				return Paper.new
			when p+r...p+r+s
				@r += 1
				return Rock.new
		end
		
	end

	def reset
		self.initialize
	end 
end

class Match
	attr_accessor :hash, :players, :state

	def initialize(hash)
		@hash = hash

		if hash.size != 2
			raise ArgumentError, "solamente puede haber dos jugadores"

		else
			@players = hash.keys
			@state = { @players[0] => 0, @players[1] => 0, :Rounds => 0}
		end
	end

	def rounds(n)
		strategy1 = @hash[@players[0]]
		strategy2 = @hash[@players[1]]
		
		player1_mov = strategy1.next(nil)
		player2_mov = strategy2.next(nil)
		
		for i in 1..n
			result = player1_mov.score(playe2_mov)
			case result
				when [0,1]
					@state[@players[0]] += 1
				when [1,0]
					@state[@players[1]] += 1
				when [0,0]
			end
			
			@status[:Rounds] += 1
			player1_mov = strategy.next(player2_mov)
			player2_mov = strategy.next(player1_mov)
		
		end
	end

	def upto(n)
		
		strategy1 = @hash[@players[0]]
		strategy2 = @hash[@players[1]]

		player1_mov = strategy1.next(nil)
		player2_mov = strategy2.next(nil)
		
		while @state[@players[0]] != n && @state[@players[1]] != n do 
			result = player1Mov.score(player2Mov)
			case result
				when [1,0]
					@state[self.p1Name] += 1
				when [0,1]
					@state[self.p2Name] += 1
				when [0,0]
			end
			
			@state[:Rounds] += 1
			player1_mov = strategy.next(player2_mov)
			player2_mov = strategy.next(player1_mov)

		end
	end

	def restart
		strategy1 = @hash[@players[0]]
		strategy1.reset
		strategy2 = @hash[@players[1]]
		strategy2.reset
		@state = {@players[0] => 0, @players[1] => 0, :Rounds => 0}
	end
end

############################################

a = Rock.new
a.to_s

x = Rock.new
y = Scissors.new
z = Paper.new

est1 = Uniform.new([:Paper,:Rock,:Scissors,:Paper])
est1.next()

hash = {:Rock => 1, :Scissors => 3, :Paper => 2}
est2 = Biased.new(hash)
est2.next()