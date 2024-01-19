class Node 
  attr_accessor :data, :left, :right
  def initialize(value = nil)
    @data = value
    @left = nil
    @right = nil
  end
end

class Tree
  attr_accessor :root, :arr, :travel
  def initialize(arr)
    @arr = arr.sort.uniq
    @root = build_tree(0, @arr.size - 1, @arr)
    @travel = @root
    @queue = [@root]
    @depth_queue = [[@root, 0]]
    @dfs_arr = []
    @boss = Node.new
    @boss.left = @root
  end

  def build_tree(start, finish, arr)
    return nil if start > finish
    mid = (start + finish) / 2
    node = Node.new(arr[mid])
    node.left = build_tree(start, mid - 1, arr)
    node.right = build_tree(mid + 1, finish, arr)
    node
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def insert(value)  
    @travel = @root  
    node = Node.new(value)
    not_finish = 1000
    while not_finish > 0
      return if @travel.data == value
      if @travel.data > value 
        return @travel.left = node if @travel.left.nil? 
        @travel = @travel.left
      else
        return @travel.right = node if @travel.right.nil? 
        @travel = @travel.right 
      end   
      not_finish -= 1
    end
  end

  def delete(value)  # the logic here is when you delete a node, you replace it with its closest right value
    @parent = nil
    @child = nil
    @right = nil
    def find_closest_right_value(node)  
      @parent = node
      @child = node.left
      if @child.nil? 
        @right = @parent.right
        @parent.right = nil
        return @parent
      end
      @right = node
      while @child.left != nil
        @parent = @child
        @child = @child.left   
      end   
      @parent.left = @child.right
      @child.right = nil
      return @child 
    end
    def find_parent(value)
      @travel = @root
      def helper(value)
        return @boss if @root.data == value
        while @travel != nil
          return @travel if (@travel.left != nil && @travel.left.data == value) || (@travel.right != nil && @travel.right.data == value)
          @travel.data > value ? @travel = @travel.left : @travel = @travel.right
        end
        nil
      end
      helper(value)
    end
    parent = find_parent(value)
    right = true
    return "value not exist to delete" if parent.nil?
    # if delete the root node
    if parent == @boss
      p "i want to delete root"
      if @root.right.nil? 
        @root = @root.left
        return
      else
        closest_right_node = find_closest_right_value(@root.right) 
        p  closest_right_node
        closest_right_node.left = @root.left
        closest_right_node.right = @right
        @root = closest_right_node
      end
    else #delete a node that is not the root
      if parent.left.nil?
        node = parent.right 
      else
        if parent.left.data == value 
          node = parent.left
          right = false
        else
          node = parent.right
        end
      end
      if node.right.nil? 
        right ? parent.right = node.left : parent.left = node.left 
      else
        closest_right_node = find_closest_right_value(node.right)  
        closest_right_node.right = @right
        closest_right_node.left = node.left
        right ? parent.right = closest_right_node : parent.left = closest_right_node 
      end
    end

  end

  def find(value)
    @travel = @root
    def helper(value)
      if @travel.data == value
        @travel
      elsif @travel.data > value
        if @travel.left.nil?
          return nil
        else
          @travel = @travel.left
          helper(value)
        end
      else
        if @travel.right.nil?
          return nil
        else
          @travel = @travel.right
          helper(value)
        end
      end  
    end
    helper(value)
  end

  def level_order(node = @root)
    @queue = [node]
    arr = []
    while !@queue.empty?
      node = @queue.shift
      @queue << node.left if !node.left.nil?
      @queue << node.right if !node.right.nil?
      arr << node.data
    end
    @queue = [@root]
    arr
  end

  def inorder_traversal(node = @root, &block)
    def helper(node)
      return if node == nil
      helper(node.left)
      @dfs_arr << (block_given? ? block.call(node.data) : node.data)
      helper(node.right)     
    end
    helper(node)
    res = @dfs_arr
    @dfs_arr = []
    res
  end

  def preorder_traversal(node = @root, &block)
    def helper(node)
      return if node == nil      
      @dfs_arr << (block_given? ? block.call(node.data) : node.data)
      helper(node.left)
      helper(node.right)     
    end
    helper(node)
    res = @dfs_arr
    @dfs_arr = []
    res
  end

  def postorder_traversal(node = @root, &block)
    def helper(node)
      return if node == nil   
      helper(node.left)
      helper(node.right) 
      @dfs_arr << (block_given? ? block.call(node.data) : node.data)
    end
    helper(node)
    res = @dfs_arr
    @dfs_arr = []
    res
  end

  def height(node)
    def helper(node, res)
      return res if node.nil?
      return [helper(node.left, res + 1), helper(node.right, res + 1)].max
    end
    helper(node, -1)
  end

  def depth(node)
    def helper(node)
      while !@depth_queue.empty?
        current_node, depth = @depth_queue.shift
        return depth if current_node == node
        @depth_queue << [current_node.left , depth + 1] if !current_node.left.nil?
        @depth_queue << [current_node.right , depth + 1] if !current_node.right.nil?
      end
    end
    res = helper(node)
    @depth_queue = [@root, 0]
    res
  end

  def balanced?(root = @root)
    @balanced = true
    def helper(node, height)
      return height if !@balanced || node.nil?
      left_height = helper(node.left, height + 1)
      right_height = helper(node.right, height + 1)
      @balanced = false if (left_height - right_height).abs > 1
      return [helper(node.left, height + 1), helper(node.right, height + 1)].max
    end
    helper(root, 0)
    @balanced
  end

  def rebalance(root = @root)
    return "already balanced" if balanced?(root)
    tree_arr = inorder_traversal(root)
    p tree_arr
    @root = build_tree(0, tree_arr.size - 1, tree_arr)
  end
end

arr = (Array.new(16) { rand(1..100) })
tree = Tree.new(arr)
tree.insert(50)
tree.insert(51)
tree.insert(52)
tree.pretty_print
p tree.balanced?
p tree.level_order

tree.rebalance
tree.pretty_print
tree.delete(51)
tree.delete(tree.root.data)
tree.pretty_print
