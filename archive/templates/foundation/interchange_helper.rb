module InterchangeHelper
  def retina_image_tag(default_name, options={})
    retina_name = default_name.gsub(%r{\.\w+$}, '@2x\0')
    image_tag(default_name, options.merge('data-interchange' => "[#{asset_path(retina_name)}, (retina)]"))
  end
end

