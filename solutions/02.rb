class TodoTask
  attr_accessor :status
  attr_accessor :description
  attr_accessor :priority
  attr_accessor :tags

  def TodoTask.set_task(current_task)
      task = TodoTask.new
      unformatted_task = current_task.split("|")
      TodoTask.set_task_methods(task, unformatted_task)
      task
  end

  def TodoTask.set_task_methods(task, get_task)
    task.status = get_task[0].strip.downcase.to_sym
    task.description = get_task[1].strip
    task.priority = get_task[2].strip.downcase.to_sym
    TodoTask.set_tags(task, get_task[3])
  end

  def TodoTask.set_tags(task, get_tags)
    task.tags = []
    return task.tags if get_tags == nil
    get_tags.split(",").each { |x| task.tags << x.strip }
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
    @to_do_tasks.each { |member| block.call(member) }
  end

  def initialize(members)
    @to_do_tasks = members
    #members.each { |s| p s }
  end

  def TodoList.parse(list)
    to_do_tasks = []
    list.split("\n").select { |x| to_do_tasks << TodoTask.set_task(x) }
    TodoList.new to_do_tasks
  end
  #
  def filter(criteria_kind)
    sublist, arr = [], []
    each { |task| arr << task.status << task.priority | Criteria.ddd(task, arr)
      filter_tasks(task, arr, criteria_kind, sublist) | arr = [] }
    TodoList.new sublist
  end
  #
  def adjoin(list)
    adjoin_list = []
    each { |x| adjoin_list << x }
    list.each { |x| adjoin_list << x }
    adjoin_list
  end

  def tasks_todo
    select { |x| x.status == :todo }.count
  end

  def tasks_in_progress
    select { |x| x.status == :current }.count
  end

  def tasks_completed
    select { |x| x.status == :done }.count
  end

  def completed?
    all? { |x| x.status == :done }
  end
end