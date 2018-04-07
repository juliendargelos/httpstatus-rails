ActionDispatch::Routing::Mapper.class_eval do
  def handles_not_found_status
    match '*path' => 'application#not_found', via: :all
  end
end
