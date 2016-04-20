class Instruction
end

class PrintInstruction < Instruction
  attr_reader :string

  def initialize(string)
    @string = string
  end
end

class GotoInstruction < Instruction
  attr_reader :line_number

  def initialize(line_number)
    @line_number = line_number
  end
end

class Program
  attr_reader :instructions_by_line_number

  def initialize
    @instructions_by_line_number = {}
  end

  def add_instruction(line_number, instruction)
    instructions_by_line_number[line_number] = instruction
  end

  def instruction_at(line_number)
    instructions_by_line_number[line_number]
  end

  def line_numbers
    instructions_by_line_number.keys.sort
  end
end

def parse_program(text)
  lines = text.split "\n"
  program = Program.new

  lines.each_with_index do |line, index|
    next unless line =~ /\S/ # skip empty lines

    unless line =~ /\A(\d+)\s+(.*)\z/
      raise "Syntax error on source line #{index + 1}: no line number"
    end

    line_number, line_contents = $1.to_i, $2

    instruction = case line_contents
    when /\APRINT\s+\"([^\"]+)\"\z/
      PrintInstruction.new($1)
    when /\AGOTO\s+(\d+)\z/
      GotoInstruction.new($1.to_i)
    else
      raise "Syntax error in program line #{line_number}: unknown instruction"
    end

    program.add_instruction line_number, instruction
  end

  program
end

def run_program(program)
  current_line = program.line_numbers.first

  loop do
    sleep 0.01
    instruction = program.instruction_at(current_line)

    case instruction
    when PrintInstruction
      puts instruction.string
    when GotoInstruction
      current_line = instruction.line_number
      next # skip the part where we figure out the next line number
    else
      raise "Runtime error on line #{current_line}: unknown instruction #{instruction.inspect}"
    end

    current_line_index = program.line_numbers.index(current_line)
    next_line_index = current_line_index + 1

    if next_line_index >= program.line_numbers.size
      break # we're at the end of the program
    else
      current_line = program.line_numbers[next_line_index]
    end
  end
end

if ARGV.size < 1
  puts "Usage: ruby natbasic.rb FILENAME"
  exit!
end

source_code = File.open(ARGV[0], 'r').read
program = parse_program(source_code)
run_program(program)