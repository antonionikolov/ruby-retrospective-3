class TodoTask
  attr_accessor :status, :description, :priority, :tags

  def self.set_task(current_task)
    status, description, priority, tags = current_task.split('|').map(&:strip)
    tags = tags.nil? ? [] : tags.split(', ')
    
    TodoTask.new status, description, priority, tags
  end

  def initialize(status, description, priority, tags)
    @status = status.downcase.to_sym
    @description = description
    @priority = priority.downcase.to_sym
    @tags = tags
  end
end
#
class Criteria
  def initialize(single, both, no)
    @single = single
    @both = both
    @no = no
  end

  attr_accessor :single
  attr_accessor :no
  attr_accessor :both

  def Criteria.status(status_kind)
    Criteria.new [status_kind], [], []
  end

  def Criteria.priority(priority_kind)
    Criteria.new [priority_kind], [], []
  end

  def Criteria.tags(tags_kind)
    Criteria.new tags_kind, [], []
  end

  def |(other)
    Criteria.new @single | other.single,
                 @both | other.both,
                 @no | other.no
  end

  def &(other)
    if (@single == [] or other.single == []) then
      self | other
    else
      Criteria.new @single & other.single,@both & other.both,@no | other.no
    end
  end

  def !
    Criteria.new @no,
                 @both,
                 @single | @both
  end

  def Criteria.ddd(task, task_array)
    task.tags.each { |x| task_array << x }
  end
end

class TodoList
  include Enumerable

  def each(&block)
    @to_do_tasks.each(&block)
  end

  def initialize(members)
    @to_do_tasks = members
  end

  def self.parse(list)
    lines = list.sprlit("\n")
    TodoList.new lines.map { |line| TodoTask.set_task(line) }
  end

  def filter(criteria_kind)
    sublist, arr = [], []
    each { |task| arr << task.status << task.priority | Criteria.ddd(task, arr)
      filter_tasks(task, arr, criteria_kind, sublist) | arr = [] }
    TodoList.new sublist
  end

  def adjoin(list)
    adjoin_list = []
    each { |x| adjoin_list << x }
    list.each { |x| adjoin_list << x }
    adjoin_list
  end

  def tasks_todo
    select { |task| task.status == :todo }.count
  end

  def tasks_in_progress
    select { |task| task.status == :current }.count
  end

  def tasks_completed
    select { |task| task.status == :done }.count
  end

  def completed?
    all? { |task| task.status == :done }
  end
end