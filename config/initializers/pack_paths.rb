Packs::Specification::Configuration.fetch.pack_paths.each do |dir|
    Dir["#{dir}/package.yml"].each do |package_yml|
      Spring.watch(package_yml)
    end
  end