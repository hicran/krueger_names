class SearchController < ApplicationController

  def index
    tags = { pre_tags: '<em class="hl">', post_tags: '</em>' }
    @names = Name.search \
      query: {
        multi_match: {
          query: params[:q],
          fields: ['name','meaning','origins']
        }
      },
      highlight: {
        tags_schema: 'styled',
        fields: {
          name:    { number_of_fragments: 0 },
          meaning: { fragment_size: 50 },
          origins: { fragment_size: 50 }
        }
      },
      size: 4000,
      sort: 'name.raw'
  end

  def suggest
    render json: Suggester.new(params)
  end
end
