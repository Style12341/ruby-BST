# frozen string literal = true

class Node
  include Comparable
  attr_accessor :left, :right, :value

  def initialize(value)
    @value = value
    @left = nil
    @right = nil
  end

  def <=>(other)
    @value <=> other.value
  end

  def is_leaf?
    @right.nil? && @left.nil?
  end
end

class Tree
  def initialize(array)
    @root = build_tree(array.sort.uniq)
  end

  def build_tree(array)
    arr = array.sort.uniq
    construct_balanced_tree(arr, 0, arr.length - 1)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def insert(value, root = @root)
    node = value.instance_of?(Node) ? value : Node.new(value)
    return node if root.nil?

    root.left = insert(node, root.left) if node < root
    root.right = insert(node, root.right) if node > root

    root
  end

  def delete(value, root = @root)
    node = value.instance_of?(Node) ? value : Node.new(value)
    return root if root.nil?

    if node < root
      root.left = delete(node, root.left)
      return root
    elsif node > root
      root.right = delete(node, root.right)
      return root
    end

    if root.left.nil?
      root.right
    elsif root.right.nil?
      root.left
    else
      parent = root
      succ = root.right
      while succ.left
        parent = succ
        succ = succ.left
      end
      if parent != root
        parent.left = succ.right
      else
        parent.right = succ.right
      end
      root.value = succ.value
      succ
    end
  end

  def find(value, root = @root)
    node = value.instance_of?(Node) ? value : Node.new(value)
    return root if root.nil?

    if node == root
      root
    elsif node < root
      find(node, root.left)
    elsif node > root
      find(node, root.right)
    end
  end

  def level_order
    ans = [] unless block_given?
    queue = []
    queue << @root
    until queue.empty?
      curr = queue.shift
      ans << curr.value if curr
      queue << curr.left if curr.left
      queue << curr.right if curr.right
      yield(curr) if block_given?
    end
    ans unless block_given?
  end

  def inorder(root = @root)
    values = []
    return [] if root.nil?

    values += inorder(root.left)
    values << root.value
    yield(root) if block_given?
    values += inorder(root.right)
    values
  end

  def preorder(root = @root)
    values = []
    return [] if root.nil?

    values << root.value
    yield(root) if block_given?
    values += inorder(root.left)
    values += inorder(root.right)
    values
  end

  def posorder(root = @root)
    values = []
    return [] if root.nil?

    values += inorder(root.left)
    values += inorder(root.right)
    values << root.value
    yield(root) if block_given?
    values
  end

  def height(node = @root)
    return -1 if node.nil?

    1 + [height(node.left), height(node.right)].max
  end

  def depth(node, root = @root)
    raise IndexError if root.nil?
    return 0 if node == root
    return 1 + depth(node, root.left) if node < root

    1 + depth(node, root.right) if node > root
  end

  def balanced?(root = @root)
    return true if root.nil?

    left = height(root.left)
    right = height(root.right)
    (left - right).abs <= 1 && balanced?(root.right) && balanced?(root.left)
  end

  def rebalance
    @root = build_tree(inorder)
  end

  private

  def construct_balanced_tree(array, start, last)
    return nil if start > last

    mid = (start + last) / 2
    root = Node.new(array[mid])
    root.left = construct_balanced_tree(array, start, mid - 1)
    root.right = construct_balanced_tree(array, mid + 1, last)
    root
  end
end



tree = Tree.new(Array.new(15) { rand(1..100) })
puts 'Balanced tree with elements between 1 and 100'
puts tree.balanced?
print 'Level Order: '
p tree.level_order
print 'Preorder: '
p tree.preorder
print 'Inorder: '
p tree.inorder
print 'Posorder: '
p tree.posorder
tree.pretty_print
10.times { tree.insert(rand(100..500)) }
puts 'After adding 10 elements greater than 100'
puts tree.balanced?
tree.pretty_print
tree.rebalance
puts 'After rebalancing'
puts tree.balanced?
tree.pretty_print
print 'Level Order: '
p tree.level_order
print 'Preorder: '
p tree.preorder
print 'Inorder: '
p tree.inorder
print 'Posorder: '
p tree.posorder