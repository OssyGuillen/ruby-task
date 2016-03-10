module BFS
	def find(start,predicate)
		queue = []

	end
	def path(start,predicate)

	end
	def walk(start,predicate)

	end
end

class BinTree
	include BFS

	attr_accessor :value, 	# Valor almacenado en el nodo
				  :left, 	# BinTree izquierdo
				  :right 	# BinTree derecho
	def initialize(v,l,r)
		@value = v
		@left = l
		@right = r
	end
	def each(b)
		if @left != nil
			yield @left
		end
		if @right != nil
			yield @right
		end
	end
end

class GraphNode
	include BFS

	attr_accessor :value,	# Valor alamacenado en el nodo
				  :children # Arreglo de sucesores GraphNode
	def initialize(v,c)
		@value = v
		@children = c
	end
	def each(b)
		if @children != nil
			@children.each do |child|
				yield child
			end
		end
	end
end