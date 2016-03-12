# Universidad Simón Bolívar
# Departamento de Computación y Tecnología de la Información
# CI-3661 - Lab. de Lenguajes de Programación I.
#
# Tarea de Ruby
#
# Implementación de la Búsqueda Generalizada:
# 							* Árboles y grafos.
# 							* Recorrido BFS.
# 							* Árboles implícitos.
#
# Autores: 			Gabriel Iglesias 11-10xxx
# 		   			Oscar Guillen    11-11264
# Grupo:     		G16
# Última edición: 	11 de marzo de 2016.

# Módulo para el recorrido BFS.
module BFS

	# Método que recorre la estructura desde start
	# haciendo uso del algoritmo de BFS.
	def traveling(start)
		queue = []
		visited = []
		# Se agrega el elemento inicial.
		queue.push(start)
		while !queue.empty?
			head = queue.shift
			if !visited.include? head
				# Agregando los hijos a la cola.
				b = lambda {|child| queue.push(child)}
				head.each(b)
				yield head
				visited << head
			end
		end
	end

	# Usando el método traveling, va recorriendo la estructura
	# usando BFS, buscando el primer elemento que cumpla con
	# el predicado dado.
	def find(start,predicate)
		start.traveling(start) do |result|
			if predicate.call(result)
				return result
			end
		end
		# Se retorna nulo si no se encontró el elemento.
		nil
	end

	# Usando el método traveling, va recorriendo la estructura usando
	# BFS, construyendo el camino desde start hasta encontrar el elemento
	# que cumpla con el predicado dado.
	def path(start,predicate)
		route = {}
		route.store(start,[])
		start.traveling(start) do |result|
			# Verificación de las claves ya contenidas en
			# el camino y la nueva recibida.
			# Muy útil para el LCR problem.
			route.each do |k,v|
				result = k if result == k
			end
			route[result] += [result]
			if predicate.call(result)
				return route[result]
			end
			b = lambda {|child| route.store(child,route[result])}
			result.each(b)
		end
    	# Se retorna nulo en caso de no encontrar el elemento.
    	nil
	end

	# Usando el método traveling, va recorriendo la estructura usando
	# BFS, aplicando la acción a cada nodo retornado por traveling
	# y retornando todos los nodos listados.
	def walk(start,action)
		visited = []
		start.traveling(start) do |result|
			result.value = action.call(result)
			visited.push(result)
		end
		# Se retorna la lista de nodos visitados.
		visited
	end
end

# Implementación de la clase Árbol Binario
class BinTree
	include BFS

	attr_accessor :value, 	# Valor almacenado en el nodo
				  :left, 	# BinTree izquierdo
				  :right 	# BinTree derecho

	# Inicialización de un arbol binario.
	# v: valor del nodo.
	# l: hijo izquierdo.
	# d: hijo derecho.
	def initialize(v,l,r)
		@value = v
		@left = l
		@right = r
	end

	# Aplicación de un bloque b sobre los hijos del
	# árbol binario.
	# b: bloque.
	def each(b)
		if @left != nil
			b.call(@left)
		end
		if @right != nil
			b.call(@right)
		end
	end
end

# Implementación de la clase Grado de arreglo de Nodos.
class GraphNode
	include BFS

	attr_accessor :value,	# Valor alamacenado en el nodo
				  :children # Arreglo de sucesores GraphNode

	# Inicialización de un arbol binario.
	# v: valor del nodo.
	# c: arreglo de hijos.
	def initialize(v,c)
		@value = v
		@children = c
	end

	# Aplicación de un bloque b sobre los hijos del
	# grafo de arreglo de nodos.
	# b: bloque.
	def each(b)
		if @children != nil
			@children.each do |child|
				b.call(child)
			end
		end
	end
end


# Implementación de la clase LoboCabraRepollo.
# para resolver el problema "Lobo, Cabra y Repollo".
class LCR
	include BFS

	attr_reader :value # Hash de símbolos.
					   # Incluye la posición del bote y
					   # lo que hay en cada orilla.

	# Inicialización de un LCR.
	# s: posición del bote.
	# l: contenido en la orilla izquierda.
	# r: contenido en la orilla derecha.
	def initialize(s,l,r)
		@value = {}
		# Se pasan todos los valores a símbolos.
		l.map { |x| x.to_s.to_sym }.uniq
    	r.map { |x| x.to_s.to_sym }.uniq
        @value.store("where",s.to_sym)
        @value.store("left",l)
        @value.store("right",r)
	end

	# Aplicación de un bloque p sobre los hijos del
	# LCR. En éste caso, los hijos son los posibles
	# estados que se pueden generar.
	# p: bloque.
	def each(p)
		# Estados para mover solo el bote de orilla.
		movShipL = LCR.new(:left,@value["left"],@value["right"])
		movShipR = LCR.new(:right,@value["left"],@value["right"])
		if @value["where"] == :right
			@value["right"].each do |x|
				estadoDer = [] + @value["right"]
				estadoIzq = [] + @value["left"]
				estadoDer.delete(x)
				estadoIzq.push(x)
				# Creación dinámica de los hijos.
				newState = LCR.new(:left,estadoIzq,estadoDer)
				p.call(newState) if newState.isValid
			end
			p.call(movShipL) if movShipL.isValid
		else
			@value["left"].each do |x|
				estadoDer = [] + @value["right"]
				estadoIzq = [] + @value["left"]
				estadoDer.push(x)
				estadoIzq.delete(x)
				# Creación dinámica de los hijos.
				newState = LCR.new(:right,estadoIzq,estadoDer)
				p.call(newState) if newState.isValid
			end
			p.call(movShipR) if movShipR.isValid
		end
	end

	# Método que resuelve el problema de busqueda del estado
	# final del problema Lobo, Cabra y Repollo.
	# Estado final: Todos los objetos del lado derecho
	# de la orilla.
	def solve
		puts "Solución: "
		# Verificación del estado final.
	    final = Proc.new{|t| (t.value["right"].sort == [:cabra,:lobo,:repollo].sort) and
	     					 (t.value["left"].sort == [])   and
	     					 (t.value["where"] == :right)}
	    path(self,final).each do |arb|
	    	puts "NUEVO ESTADO ->  "+ arb.to_s
	    	puts " "
	    end
	    return "Finalizado"
	end	

	# Método que imprime un LCR agradable a la vista.
	def to_s
    	"Posicion Bote: #{@value["where"]} | Izq: #{@value["left"]} | Der: #{@value["right"]}"
  	end
	

  	# Método que verifica si un estado nuevo es válido.
  	# Para ello, no pueden estar todos ls objetos de un lado
  	# y el bote del otro. Además, el lobo y la cabra no pueden
  	# estar solos en un orilla. Igualmente, no pueden estar
  	# solos la cabra y el repollo.
	def isValid
		# Lado derecho de la orilla.
		if @value["where"] == :right
			if (@value["left"].include?(:lobo) and @value["left"].include?(:cabra)) or
				(@value["left"].include?(:cabra) and @value["left"].include?(:repollo))
				false
			else
				true
			end
		# Lado izquierdo de la orilla.
		else
			if (@value["right"].include?(:lobo) and @value["right"].include?(:cabra)) or
				(@value["right"].include?(:cabra) and @value["right"].include?(:repollo))
				false
			else
				true
			end
		end
	end

	# Método que sobreescribe el == para LCR. Esta necesidad surge de 
	# tener que comparar elementos en el método PATH, del bfs para no
	# repetir claves en el recorrido. A pesar de ser dos objetos distintos,
	# dos objetos con parámetros iguales representan el mismo estado.
	def ==(obj)
    	b = (@value["where"] == obj.value["where"])
      	b = b and (@value["left"].sort == obj.value["left"].sort)
        b and (@value["right"].sort == obj.value["right"].sort)
  	end
end