#!/usr/bin/env ruby

# Universidad Simón Bolívar
# Departamento de Computación y Tecnología de la Información
# CI3661 - Laboratorio de Lenguajes de Programación I
# Trimestre Enero - Marzo 2016.
# 
# Tarea Ruby
#
# Juego ”Piedra, Papel o Tijeras”
#  
# Autores:          Gabriel Iglesias 11-10476.
#                   Oscar Guillen    11-11264.
# Grupo:     		G16
# Última edición: 	11 de marzo de 2016.

# Clase abstracta para movimientos.
class Movement

	# Muestra el invocante como un string.
	def to_s 
		self.class.name
	end
end

# Clase que representa la jugada piedra. 
class Rock < Movement

	# Determina el ganador entre una jugada de tipo Rock y una de tipo m.
	def score(m)
		m.compareRock
	end

	# Determina el ganador entre dos movimientos Rock. 
	# Se retorna la tupla para empate.
	def compareRock
		return [0,0]
	end

	# Determina el ganador entre un movimiento Rock y uno Paper.
	def comparePaper
		return [0,1]
	end

	# Determina el ganador entre un movimiento Rock y uno Scissors.
	def compareScissors
		return [1,0]
	end
end

# Clase que representa la jugada papel.
class Paper < Movement
	
	# Determina el ganador entre una jugada de tipo Paper y una de tipo m.
	def score(m)
		m.comparePaper
	end

	# Determina el ganador entre un movimiento Paper y uno Rock.
	def compareRock
		return [0,1]
	end

	# Determina el ganador entre dos movimientos Paper. 
	# Se retorna la tupla para empate.	
	def comparePaper
		return [0,0]
	end

	# Determina el ganador entre un movimiento Paper y uno Scissors.
	def compareScissors
		return [0,1]
	end
end

# Clase que representa la jugada tijeras.
class Scissors < Movement
	
	# Determina el ganador entre una jugada de tipo Scissors y una de tipo m.
	def score(m)
		m.compareScissors
	end

	# Determina el ganador entre un movimiento Scissors y uno Rock.
	def compareRock
		return [0,1]
	end

	# Determina el ganador entre un movimiento Scsissors y uno Paper.
	def comparePaper
		return [1,0]
	end

	# Determina el ganador entre dos movimientos Scissors. 
	# Se retorna la tupla para empate.
	def compareScissors
		return [0,0]
	end
end

# Clase abstracta para estrategias.
class Strategy
	
	SEED = 42                # Constante para la semilla.
	PRNG = Random.new(SEED)  # Constante para la clase Random para generar 
	                         # números aleatorios. 

	# Muestra el invocante como un string.
	def to_s
		self.class.name	
	end

	# Devuelve el siguiente movimiento de la estrategia invocante.
	def next(mov = nil)
		raise RunTimeError, 
			  "No existe siguiente movimiento para una estrategia abstracta"
	end

	# Lleva la estrategia al estado inicial.
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

		# Se eliminan los duplicados de la lista de movimientos.
		@list = list.uniq
		
		# Chequea que la lista de movimientos no sea vacia.
		if @list.empty? 
			raise ArgumentError, "Error: lista de movimientos vacia"
		end

	end

	# Devuelve el siguiente movimiento de la estrategia invocante.
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

	# Muestra la estrategia invocante como un string.
	def to_s
		"Estrategia " + super + ". Jugadas Posibles: " + @list.to_s
	end

	# Lleva la estrategia al estado inicial.
	def reset
	end
end

# Estrategia en las jugadas de la lista de jugadas posibles tienen 
# distintas probabilidades de ser elegidas.
class Biased < Strategy

	attr_reader :hash, :pr

	def initialize(hash)
		@hash = hash

		# Chequea que el hash de movimientos no sea vacio.
		if @hash.empty? 
			raise ArgumentError, "hash de movimientos vacio"
		end
	

		@pr = @hash.values.inject(:+)
	end

	# Devuelve el siguiente movimiento de la estrategia invocante.
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

	# Muestra la estrategia invocante como un string.
	def to_s
		"Estrategia " + super + ". Jugadas Posibles: " + @hash.to_s
	end

	# Lleva la estrategia al estado inicial.
	def reset
	end
end

# Estrategia en la que se juega lo mismo que jugó el oponente en el 
# turno anterior.
class Mirror < Strategy

	attr_reader :initial_mov      # Movimiento inicial.
	attr_accessor :opponent_mov   # Movimiento del oponente.

	def initialize(mov)
		if !mov.is_a?(Movement)
			raise ArgumentError, "el argumento no es un movimiento permitido"
		else
			@initial_mov = @opponent_mov = mov
		end
	
	end

	# Devuelve el siguiente movimiento de la estrategia invocante.
	def next(mov)
		if mov
			@opponent_mov = mov
		end
		
		return @opponent_mov
	end

	# Muestra la estrategia invocante como un string.
	def to_s
		"Estrategia " + super + ". Movimiento Inicial: " + @initial_mov.to_s
	end

	# Lleva la estrategia al estado inicial.
	def reset
		@opponent_mov = @initial_mov
	end
end

# Estrategia en la que la jugada depende de las jugadas anteriores hechas 
# por el oponente.
class Smart < Strategy

	attr_accessor :p, :r, :s
	
	def initialize
		@p = 0  # Número de jugadas Paper.
		@r = 0  # Número de jugadas Rock.
		@s = 0  # Número de jugadas Scissors.
	end

	# Devuelve el siguiente movimiento de la estrategia invocante.
	def next(mov)
		random = PRNG.rand(p+r+s-1)

		# Caso en que no es la primera jugada
		if mov 
			# Aumenta la frecuencia de la jugada recien hecha por el oponente.
			case mov.to_sym
				when :Rock
					@r += 1
				when :Paper
					@p += 1
				when :Scissors
					@s += 1				
			end 

			# Decide cual sera la siguiente jugada
			case random
				when 0...p
					return Scissors.new
				when p...p+r
					return Paper.new
				when p+r...p+r+s
					return Rock.new
			end

		# Caso en el que es la primera jugada.
		else
			aux = [:R,:P,:S]
			random = PRNG.rand(2)

			case aux[random]
				when :R
					return Rock.new
				when :P
					return Paper.new
				when :S
					return Scissors.new 
			end
		end
	end

	# Muestra la estrategia invocante como un string.	
	def to_s
		"Estrategia " + super
	end

	# Lleva la estrategia al estado inicial.
	def reset
		self.initialize
	end 
end

class Match
	attr_accessor :hash, :players, :state

	def initialize(hash)
		@hash = hash

		# Chequea que sólo existan dos jugadores
		if hash.size != 2
			raise ArgumentError, "solamente puede haber dos jugadores"

		# Inicializa un arrehlo con los jugadores y un hash para guardar el estado del juego.
		else
			@players = hash.keys
			@state = { @players[0] => 0, @players[1] => 0, :Rounds => 0}
		end
	end

	# Realiza n rondas entre utilizando las etsrategias definidas en la 
	# instancia de clase.
	def rounds(n)

		# Se Asignan las estrategias de los jugadores.
		strategy1 = @hash[@players[0]] 
		strategy2 = @hash[@players[1]]
		
		# Se crea el primer movimiento de cada estrategia.
		player1_mov = strategy1.next(nil)
		player2_mov = strategy2.next(nil)
		
		# Realiza n jugadas y modifica el estado del juego.
		for i in 1..n
			result = player1_mov.score(player2_mov)
			case result
				when [0,1]
					@state[@players[0]] += 1
				when [1,0]
					@state[@players[1]] += 1
				when [0,0]
			end
			
			@state[:Rounds] += 1
			player1_mov = strategy1.next(player2_mov)
			player2_mov = strategy2.next(player1_mov)
		
		end

		return @state
	end

	# Permite a los jugadores jugar hasta que alguno de ellos gane n rondas. 
	# Cada jugador utiliza las estrategias definidas en la instancia de clase.	
	def upto(n)
		
		# Se Asignan las estrategias de los jugadores.
		strategy1 = @hash[@players[0]]
		strategy2 = @hash[@players[1]]

		# Se crea el primer movimiento de cada estrategia.
		player1_mov = strategy1.next(nil)
		player2_mov = strategy2.next(nil)
		
		# Itera hasta que uno de los jugadores alcanze las n rondas ganadas.
		while (@state[@players[0]] < n) && (@state[@players[1]] < n) do 
			result = player1_mov.score(player2_mov)
			case result
				when [1,0]
					@state[@players[0]] += 1
				when [0,1]
					@state[@players[1]] += 1
				when [0,0]
			end
			
			@state[:Rounds] += 1
			player1_mov = strategy1.next(player2_mov)
			player2_mov = strategy2.next(player1_mov)

		end

		return @state
	end

	# Lleva el juego al estado inicial.
	def restart
		strategy1 = @hash[@players[0]]
		strategy1.reset
		strategy2 = @hash[@players[1]]
		strategy2.reset
		@state = {@players[0] => 0, @players[1] => 0, :Rounds => 0}
	end
end
