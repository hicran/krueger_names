class Name
  include Elasticsearch::Persistence::Model

  index_name :name

  analyzed_and_raw = { fields: {
      name: { type: 'text' },
      raw:  { type: 'keyword' }
  } }
  attribute :name, String, mapping: analyzed_and_raw

  attribute :states, String, default: []
  attribute :genders, String, default: []
  attribute :origins, String, default: []
  attribute :meaning, String, default: ''
  attribute :total_occurence, Integer
  attribute :first_seen_year, Integer
  attribute :first_seen_year, Integer

  # TODO
  # attribute :years_and_occurences, Hashie::Mash, mapping: {
  #   type: 'object',
  #   properties: {
  #       year: {type: Integer},
  #       occurence: {type: Integer}
  #   }
  # }

  def to_param
    [id, name.parameterize].join('-')
  end
end
