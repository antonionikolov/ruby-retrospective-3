module Asm
  module OperationInstructions
    def mov_instruction(destination_register, source)
      set_register = set_value(source)
      instance_variable_set("@#{destination_register}", set_register)
    end

    def inc_instruction(destination_register, value)
      value = 1 if value == nil
      set_register = set_value(value)
      set_register += set_value(destination_register)
      instance_variable_set("@#{destination_register}", set_register)
    end

    def dec_instruction(destination_register, value)
      value = 1 if value == nil
      set_register = set_value(value)
      set_register = set_value(destination_register) - set_register
      instance_variable_set("@#{destination_register}", set_register)
    end

    def cmp_instruction(register, value)
      @cmp = set_value(register) <=> set_value(value)
    end

    def set_value(value)
      if value.class == Symbol
        instance_variable_get("@#{value}")
      else
        value
      end
    end
  end

  module JumpInstructions
    def je_instruction(where)
      if @cmp == 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:je, where]) + 1)
      end
    end

    def jne_instruction(where)
      if @cmp != 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:jne, where]) + 1)
      end
    end

    def jl_instruction(where)
      if @cmp < 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:jl, where]) + 1)
      end
    end

    def jle_instruction(where)
      if @cmp <= 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:jle, where]) + 1)
      end
    end

    def jg_instruction(where)
      if @cmp > 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:jg, where]) + 1)
      end
    end

    def jge_instruction(where)
      if @cmp >= 0
        jmp_instruction(where)
      else
        execute_instructions(@operations_queue.index([:jge, where]) + 1)
      end
    end
  end

  class AssemblerSubset
    def method_missing(method)
      method
    end

    def initialize
      @ax, @bx, @cx, @dx = 0, 0, 0, 0
      @operations_queue = []
      @cmp = 0
    end

    instructions = [:mov, :inc, :dec, :cmp, :label,
                    :jmp, :je, :jne, :jl, :jle, :jg, :jge]

    instructions.each do |instruction_name|
      define_method instruction_name do |*args|
        @operations_queue << [instruction_name, *args]
      end
    end

    def execute_instructions(drop_index)
      @operations_queue.drop(drop_index).each do |clue|
        next if clue[0] == :label
        send (clue[0].to_s + "_instruction"), clue[1], clue[2] if check(clue)
        return send (clue[0].to_s + "_instruction"), clue[1] if !check(clue)
      end
      [@ax, @bx, @cx, @dx]
    end

    def check(clue)
      [:mov, :inc, :dec, :cmp].include? clue[0]
    end

    private

    def jmp_instruction(where)
      if where.class == Symbol
        execute_instructions(@operations_queue.index([:label, where]) + 1)
      else
        execute_instructions(where + label_count(where))
      end
    end

    def label_count(where)
      cut_tail = @operations_queue.size - where - 1
      label_count =
        @operations_queue.reverse.drop(cut_tail).reverse.select do |label|
          label[0] == :label
        end.size
    end

    include OperationInstructions
    include JumpInstructions
  end

  def self.asm(&block)
    task = AssemblerSubset.new
    task.instance_eval &block
    task.execute_instructions(0)
  end
end