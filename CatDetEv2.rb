=begin A program to emulate the evolution of the ability to categorize stimuli.  "brain"
models two neurons, Toward and Away, in the nervous system of ten animals.  Goal is to
evolve through natural selection the ability to "categorize" stimuli as either small
or large by moving Toward small, Away from large.  Because such behavior is adaptive,
it will likely drive the evolution of neurons capable of such categorization. Postulate
a 4x4 detector that produces a stimulus (detectorStim) consisting of 1 to 16 lit elements in any pattern.
This stimulus is then presented to a "counter" neural network that fires a different neuron
depending on the number of lit elements in the detectorStim.
This output is then sent to the two neurons in the "brain" of each of the ten animal.  Each animal
brain produces an output (i.e., turn toward, turn away, do nothing) which constitutes a
classifier, producing a confusion matrix in which each outcome can be assigned an
adaptive value. The produced adaptive value is summed for both neurons producing fitness
score for the animal.  Through "natural selection" the animal with the brain that is
the best classifer is replicated by replacing the worst animal.  The simulation runs until
one animal is capable of producing an exact adaptive response, that is, of turning towards a 
"small" stimulus (1, 2, or 3 lit elements) and away from a "large" stimulus (14, 15, or 16 
lit elements) and further, doesn't turn towards or away from stimuli neither small nor
large [(4..13) lit elements.]
=end
require 'matrix'
Stimmax=15 #size of stimulus vector
Behavmax=19 # 2 behaviors per each of 10 animals
BrainThrshold=15 # Threshold value for neuronal firing of brain neurons
CommonMax=BrainThrshold + 3 # maximum value of brain elements
Variation = 5 # limit on random variation in synaptic efficacy per generation
stimulus=Matrix.column_vector([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) # from 4x4 binary dector
detectorStim=Matrix.column_vector([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]) 
# stimulus=Matrix.column_vector([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
brain = Matrix.build(20,16) {0} # 20 neurons with 16 synapses each
fitness=Matrix.row_vector([0,0,0,0,0,0,0,0,0,0]) # records fitness scores
TOWARD = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18].freeze #defines Toward neurons
AWAY = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19].freeze #defines Away neurons
bestFitns=33 # value of fitness given perfect descrimination
Encounters= 16 # one each with each number of lit detector elements
digits = (1..16).to_a
shuffled_digits = digits.shuffle # an array to generate 16 detectorStims
shuffled_digits_enum = shuffled_digits.to_enum
# Make counter matrix to count number of lit detectorStim elements
CounterThrshold=247
CounterMax=15 # number of neurons in counter matrix
counter = Matrix.build(16,16) { 0 }
for i in (0..CounterMax)
	for j in (0..Stimmax)
	counter[i,j] = 256/(16-i)
	end # j
end #i
#srand(1094) 
for i in (0..Behavmax)
		for j in (0..Stimmax)
				if rand > 0.5 then brain[i,j] = rand(1..CommonMax) end # (CM-X..CM) ENSURE FIRING
		end # j
end #i  AVERAGE NON-ZERO INITIAL VALUE = 27
generations=0
# BEGIN PROGRAM
while fitness.max < bestFitns do
	fitness=Matrix.row_vector([0,0,0,0,0,0,0,0,0,0]) # calculate fitness each generation
	shuffled_digits = (1..16).to_a.shuffle.uniq
	for e in (1..Encounters)
		num_elements_to_set = shuffled_digits[e-1]
		detectorStim = Matrix.column_vector([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
		num_elements_to_set.times do
			random_index = rand(16)
			while detectorStim[random_index, 0] == 1
			  random_index = rand(16)
			end
			detectorStim[random_index, 0] = 1
		end # do
		elementsOn = counter * detectorStim
		numOfElementsOn = nil
		for i in (0..CounterMax)
			if elementsOn[i, 0] >= CounterThrshold
			  numOfElementsOn = 16 - i
			  break
			end
		end
		stimulus[numOfElementsOn-1,0]=1
		case numOfElementsOn
		when 1..3
				theStim = 's'
		when 4..13
				theStim = 'c'
		when 14..16
				theStim = 'l'
		end #case
        # break if numOfElementsOn
		behavior=brain*stimulus
		#determine fitness per confusion matrix
		for i in TOWARD #  [0,2,4,6,8,10,12,14,16,18]
			if behavior[i,0] >= BrainThrshold and theStim == 's' then fitness[0,i/2]+= 5 end # TP
			if behavior[i,0] >= BrainThrshold and theStim == 'l' then fitness[0,i/2]-= 6 end # FP
			if behavior[i,0] >= BrainThrshold and theStim == 'c' then fitness[0,i/2]-= 1 end # FP
			if behavior[i,0] <  BrainThrshold and theStim == 's' then fitness[0,i/2]-= 2 end # FN
			if behavior[i,0] <  BrainThrshold and theStim == 'l' then fitness[0,i/2]+= 2 end # TN
			if behavior[i,0] <  BrainThrshold and theStim == 'c' then fitness[0,i/2]+= 0 end # TN
		end #i
		for i in AWAY # [1,3,5,7,9,11,13,15,17,19]
			if behavior[i,0] >= BrainThrshold and theStim == 's' then fitness[0,(i-1)/2]-= 3 end # FP
			if behavior[i,0] >= BrainThrshold and theStim == 'l' then fitness[0,(i-1)/2]+= 4 end # TP
			if behavior[i,0] >= BrainThrshold and theStim == 'c' then fitness[0,(i-1)/2]-= 1 end # FP
			if behavior[i,0] <  BrainThrshold and theStim == 's' then fitness[0,(i-1)/2]+= 0 end # TN
			if behavior[i,0] <  BrainThrshold and theStim == 'l' then fitness[0,(i-1)/2]-= 2 end # FN
			if behavior[i,0] <  BrainThrshold and theStim == 'c' then fitness[0,(i-1)/2]+= 0 end # TN
		end #i
		stimulus=Matrix.column_vector([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
	end # Encounters
	# REPRODUCE: replace worst animal with clone of best, add variation to all
	bestAnimal=fitness.find_index(fitness.max)
	thebestAnimal=bestAnimal[1]*2
	worstAnimal=fitness.find_index(fitness.min)
	theworstAnimal=worstAnimal[1]*2
	for j in (0..Stimmax)
			brain[theworstAnimal,j]=brain[thebestAnimal,j]
			brain[theworstAnimal+1,j]=brain[thebestAnimal+1,j]
	end #j
	# add variation each generation to one connection per neuron
	for i in (0..Behavmax)
		j=rand(0..Stimmax)
		brain[i,j] += rand(-Variation..Variation)
		if brain[i,j] > CommonMax then brain[i,j] = CommonMax end
		if brain[i,j] < 0 then brain[i,j] = 0 end
	end #for i
	generations+=1
	break if generations > 1000 # EXIT PROGRAM IF DESIRED FOR TROUBLESHOOTING
end # while fitness
puts
puts "generations=#{generations}   threshold=#{BrainThrshold} CommonMax=#{CommonMax}"
puts "fitness = #{fitness}"
puts
#brain.to_a.each { |r| puts r.inspect }
