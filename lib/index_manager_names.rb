require 'open-uri'

class IndexManagerNames
  def self.create_index(options={})
    client     = Name.gateway.client
    index_name = Name.index_name

    client.indices.delete index: index_name rescue nil if options[:force]

    settings = Name.settings.to_hash.merge(Name.settings.to_hash)
    mappings = Name.mappings.to_hash.merge(Name.mappings.to_hash)

    client.indices.create index: index_name,
                          body: {
                            settings: settings.to_hash,
                            mappings: mappings.to_hash }
  end

  def self.import_from_data
    create_index force: true

    names = {}
    Dir.glob(File.join(File.dirname(__FILE__), '../data/names_by_state', "*.TXT")).each do |file_name|
      puts file_name
      File.open(file_name).each_line do |line|
        state,gender,year,name,occurence = line.strip.split(",")
        year = year.to_i
        occurence = occurence.to_i
        gender = gender == 'F' ? 'Female' : 'Male'
        # TODO
        next if gender == 'Male'
        names[name] ||= {states: [],
                         genders: [],
                         origins: [],
                         # years_and_occurences:{},
                         total_occurence: 0,
                         first_seen_year: 2017,
                         last_seen_year: 1900}
        names[name][:states] << state unless names[name][:states].include?(state)
        names[name][:genders] << gender unless names[name][:genders].include?(gender)
        # names[name][:years_and_occurences][year] ||= 0
        # names[name][:years_and_occurences][year] = names[name][:years_and_occurences][year] + occurence.to_i
        names[name][:first_seen_year] = year < names[name][:first_seen_year] ? year : names[name][:first_seen_year]
        names[name][:last_seen_year] = year > names[name][:last_seen_year] ? year : names[name][:last_seen_year]
        names[name][:total_occurence] = names[name][:total_occurence] + occurence.to_i
      end
      puts "finished #{file_name}"
    end
    Dir.glob(File.join(File.dirname(__FILE__), '../data/names_by_country', "*.txt")).each do |file_name|
      puts file_name
      File.open(file_name).each_line do |line|
        name = line.strip
        origin = file_name.strip.split('.')[2].split('/').last
        next unless names[name]
        names[name][:origins] << origin unless names[name][:origins].include?(origin)
      end
      puts "finished #{file_name}"
    end

    File.open(File.join(File.dirname(__FILE__), '../data/names_by_letter/all_names.csv')).each_line do |line|
      name,gender,origin,meaning = line.strip.split("|")
      origins = origin.split(',').map{|o| o.strip}
      name = name.strip.capitalize
      next unless names[name]
      origins.each do |origin|
        names[name][:origins] << origin unless names[name][:origins].include?(origin)
      end
      names[name][:meaning] = meaning
    end

    File.open(File.join(File.dirname(__FILE__), '../data/names_by_meaning/all_names.csv')).each_line do |line|
      puts line
      name,origin,meaning, other_names = line.strip.split("|")
      other_names = other_names ? other_names.split(',').map{|o| o.strip} : []
      other_names << name
      origins = origin.split(',').map{|o| o.strip}
      other_names.each do |name|
        next unless names[name]
        origins.each do |origin|
          names[name][:origins] << origin unless names[name][:origins].include?(origin)
        end
        names[name][:meaning] = meaning
      end
    end

    names.each do |name, name_hash|
      name_hash.update(id: name, name: name)
      Name.create name_hash, id: name_hash[:id]
    end; nil
  end
end
