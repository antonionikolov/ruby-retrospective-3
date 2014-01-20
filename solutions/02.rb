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

class Criteria
  attr_reader :allowed

  def initialize(allowed)
    @allowed = allowed
  end

  class << self
    def status(status)
      Criteria.new -> task { task.status == status }
    end

    def priority(priority)
      Criteria.new -> task { task.priority == priority }
    end

    def tags(tags)
      Criteria.new -> task { (task.tags & tags).length == tags.length }
    end
  end

  def &(other)
    Criteria.new -> task do
      allowed.(task) && other.allowed.(task)
    end
  end

  def |(other)
    Criteria.new -> task do
      allowed.(task) || other.allowed.(task)
    end
  end

  def !
    Criteria.new -> task { not allowed.(task) }
  end
end

class TodoList
  include Enumerable

  def each(&block)
    @to_do_tasks.each(&block)
  end

  attr_accessor :to_do_tasks

  def initialize(to_do_tasks)
    @to_do_tasks = to_do_tasks
  end

  def self.parse(list)
    lines = list.split("\n")
    TodoList.new lines.map { |line| TodoTask.set_task(line) }
  end

  def filter(criteria)
    TodoList.new @to_do_tasks.select { |task| criteria.allowed.(task) }
  end

  def adjoin(other)
    TodoList.new (@to_do_tasks + other.to_do_tasks).uniq
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