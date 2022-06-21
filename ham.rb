class Question
  attr_accessor :id, :prompt, :correct_answer, :distractors

  def initialize(id, prompt, correct_answer, distractors)
    @id = id
    @prompt = prompt
    @correct_answer = correct_answer
    @distractors = distractors
  end

  def ask(give_away: false)
    answer_letters = %w[A B C D]
    correct_answer_index = rand(4)
    correct_answer_letter = answer_letters[correct_answer_index]

    print @id
    if give_away
      puts " (#{correct_answer_letter})"
    else
      puts
    end
    puts "\033[1m#{@prompt}\033[0m"
    answers = @distractors.shuffle.insert(correct_answer_index, @correct_answer)

    answer_letters.zip(answers).each do |letter, answer|
      puts "#{letter}. #{answer}"
    end

    print '> '
    while (guess = gets.match(/([ABCD])/i).to_a&.first&.upcase).nil?
      puts 'Answer must be one of A, B, C or D!'
      print '> '
    end

    if guess == correct_answer_letter
      puts "#{guess} is correct!"
      return true
    else
      puts "Incorrect! The correct answer is #{correct_answer_letter}."
      return false
    end
  end
end

target_file = 'technician_06302022.txt'
if !File.exist?(target_file)
  if ENV['HAM_DIR'].nil?
    puts '$HAM_DIR environment variable not set!'
    exit 1
  else
    target_file = "#{ENV['HAM_DIR']}/#{target_file}"
  end
end

num_questions = ARGV.shift&.to_i || 1

questions =
  File.read(target_file).split("~~\n").map.with_index do |question_raw, i|
    lines = question_raw.split(/\n/)

    raise "not enough lines in question #{i}!" if lines.length < 6

    _, id, correct_answer_letter = lines[0].match(/(T\d[A-Z]\d+) \(([ABCD])\)/).to_a
    correct_answer_index = %w[A B C D].index(correct_answer_letter)

    prompt = lines[1]

    answers = lines[2, 4].map { |answer| answer.gsub(/^[ABCD]\.\s*/, '') }

    correct_answer = answers.delete_at(correct_answer_index)

    Question.new(id, prompt, correct_answer, answers)
  end

num_correct = 0
questions.shuffle.first(num_questions).each_with_index do |question, count|
  num_correct += question.ask ? 1 : 0

  if count < num_questions - 1
    print 'Press Enter to continue...'
    gets
  end

  puts
end

if num_questions > 1
  puts "#{num_correct} / #{num_questions} correct."
  puts
end
