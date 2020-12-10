#!/usr/bin/env ruby

require 'repomd_parser'

class OutdatedPackagesCleaner
  def initialize(mirror_dir)
    raise "#{mirror_dir} doesn't exist or isn't a directory" unless File.exist?(mirror_dir) and File.directory?(mirror_dir)
    @mirror_dir = mirror_dir
    @packages = {}
    @inodes = {}
  end

  def start
    repo_dirs = []
    referenced_size = 0
    outdated_size = 0
    outdated_files = 0

    Dir[@mirror_dir + '/**/*'].each do |f|
      next unless File.directory?(f)
      if File.basename(f) == 'repodata'
        repo_dirs << File.expand_path(File.join(f, '..'))
      end
    end

    repo_dirs.each do |repo_dir|
      Dir[repo_dir + '/**/*'].each do |f|
        @packages[f] = true if f =~ /rpm$/
      end

      primary_xml = nil
      delta_xml = nil
      metadata_files = RepomdParser::RepomdXmlParser.new(File.join(repo_dir, 'repodata/repomd.xml')).parse
      metadata_files.each do |metadata_file|
        primary_xml = File.join(repo_dir, metadata_file.location) if metadata_file.type == :primary
        delta_xml = File.join(repo_dir, metadata_file.location) if metadata_file.type == :deltainfo
      end

      if primary_xml
        rpm_packages = RepomdParser::PrimaryXmlParser.new(primary_xml).parse
        rpm_packages.each do |rpm|
          full_path = File.join(repo_dir, rpm.location)
          referenced_size += get_size(full_path)
          @packages.delete(full_path)
        end
      end

      next unless delta_xml
      drpm_packages = RepomdParser::DeltainfoXmlParser.new(delta_xml).parse
      drpm_packages.each do |rpm|
        full_path = File.join(repo_dir, rpm.location)
        referenced_size += get_size(full_path)
        @packages.delete(full_path)
      end
    end

    @packages.keys.each do |file|
      next if File.directory?(file)
      outdated_size += get_size(file)
      outdated_files += 1
      File.delete(file)
    end

    puts format('Number of outdated files removed: % 6d, disk space freed (MB): % 6d', outdated_files, outdated_size / 1024 / 1024)
  end

  protected

  def get_size(full_path)
    return 0 unless File.exist?(full_path)
    ino = File.stat(full_path).ino
    return 0 if @inodes[ino]
    @inodes[ino] = true
    File.size(full_path)
  end
end

mirror_dir = ARGV[0] || '/srv/www/htdocs/'
OutdatedPackagesCleaner.new(mirror_dir).start
