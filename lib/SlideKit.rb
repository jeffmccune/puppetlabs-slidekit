class SlideKit
  require 'fileutils'
  require 'yaml'
  def initialize project, out='output', conf='conf', src='src'
    @project = project 
    @conf = conf
    @src = src
    @out = out 
    @yaml = "#{@conf}/#{@project}.yaml"  
    @info = "#{@conf}/#{@project}.info"  
    @textile = "#{@out}/#{@project}.textile"  
    @slides = "src/slides"
  end

  def parse()
    header= nil
    files = []
    YAML::load(File.open(@yaml)).each do |value|
      if value.class == String
        if value =~ /\s*Section\s+(.+)/
          files.push({:section => $1})
        else
          header = value
        end
      else
        raise 'no header' unless(header)
        value.each do |element|
          files.push({:header => header.gsub(' ', "_"), :element => element})
        end
      end
    end
    return files
  end

  def compile(files)
    FileUtils.mkdir_p(@out)
    f = File.open(@textile, 'w')
    f.print File.read(@info)
    files.each do |element| 
      if element[:section]
        f.print "\nh1. #{element[:section]}\n"
      else
        argies=element[:element].split(',')
        element[:element]=argies.shift
        argies.collect! {|x| x.gsub(' ', '')}
        filename="#{@slides}/#{element[:header]}/#{element[:element]}.textile"
        # delete all of the arguments
        header = element[:header].gsub('_',' ')
        f.print "\nh1. #{header}\n\n#{File.read(filename)}"
      end
    end
    f.close
  end

  def build() 
   files = self.parse()
   self.compile(files)
  end 

end
