#
# methods/emc/matrix_intensity.rb - Common method for calculating intensity matrix for model
#
# $Id: matrix_intensity.rb,v 1.7 2006/06/06 08:11:19 pac Exp $
#

module Methods

   # Creating intesnsity matrix for given model
   def Methods.matrix(model)
      matrix = []
      model.nodes.each_with_index do |n1, idx1|
         row = []
         # Initializing row elements intenstity value
         sum = 0.0
         model.nodes.each_with_index do |n2, idx2|
            # Finding outcome links for n1 that connect to n2
            found  = n1.outcome(model).select { |link| link.dest == n2 }
            # Collecting links intensities
            intens = found.collect { |link| link.intensity }
            # Calculating common matrix cell intensity
            intensity = 0.0
            intens.each { |i| intensity += i }
            row[idx2] = intensity
            # Updating sum with new intensity
            sum += intensity
         end
         # Correcting diagonal element
         row[idx1] = -sum
         # Appending matrix row
         matrix << row
      end
      return matrix
   end # matrix

end # module Methods