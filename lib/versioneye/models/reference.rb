class Reference  < Versioneye::Model

  include Mongoid::Document
  include Mongoid::Timestamps

  field :language, type: String
  field :prod_key, type: String

  field :group_id    , type: String   # Maven specific
  field :artifact_id , type: String   # Maven specific

  field :ref_count, type: Integer
  field :prod_keys, type: Array

  index({ language: 1, prod_key: 1 }, { name: "language_prod_key_index" , background: true })

  def update_from prod_keys
    self.ref_count = prod_keys.count
    self.prod_keys = prod_keys
  end

  def products page = 0
    page = page.to_i - 1
    page = 0 if page.to_i < 0

    per_page = 30
    skip  = page * per_page
    limit = skip + per_page
    filter = prod_keys[skip..limit]
    return nil if filter.nil? || filter.empty?

    if group_id && artifact_id
      return Product.where(:group_id.ne => nil, :artifact_id.ne => nil, :prod_key.in => filter).desc(:used_by_count)
    else
      return Product.where(:language => language, :prod_key.in => filter).desc(:used_by_count)
    end
  rescue => e
    log.error e.message
    nil
  end

  def self.find_by language, prod_key
    Reference.where(:language => language, :prod_key => prod_key).shift
  end

end
