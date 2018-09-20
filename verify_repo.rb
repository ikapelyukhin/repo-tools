#!/usr/bin/env ruby

require 'bundler/setup'
require 'typhoeus'
require 'uri'
require 'tmpdir'
require 'fileutils'
require 'progress_bar'
require 'repomd_parser'

class RepoVerifier
  def initialize(repo_url, token)
    repo_url += '/' unless repo_url =~ /\/$/
    @repo_url = repo_url
    @token = token
  end

  def verify
    @tempdir = Dir.mktmpdir('verify-repo')
    repomd_file = get('repodata/repomd.xml')

    metadata_files = Hash.new { |hash, key| hash[key] = [] }

    RepomdParser::RepomdXmlParser.new(repomd_file).parse.each do |xml_file|
      metadata_files[xml_file.type] << xml_file if %i[primary deltainfo].include?(xml_file.type)
    end

    hydra = Typhoeus::Hydra.new
    pb = ProgressBar.new
    pb.max = 0

    broken_files = []

    metadata_files[:primary].each do |xml_file|
      filename = File.basename(xml_file.location)

      primary_xml_file = get(xml_file.location)

      rpms = RepomdParser::PrimaryXmlParser.new(primary_xml_file).parse

      rpms.each do |package|
        uri = URI.join(@repo_url, package.location)
        uri.query = @token

        request = Typhoeus::Request.new(uri.to_s, followlocation: true, method: :head)
        request.on_complete do |response|
          if response.success?
            actual_size = response.headers["Content-Length"].to_i

            if (actual_size != package.size.to_i)
              broken_files << "#{package.location}, actual size: #{actual_size}, metadata size: #{package.size}"
            end

            pb.increment!
          else
            raise "Something went wrong: #{uri.to_s}"
          end
        end

        hydra.queue(request)
        pb.max = pb.max + 1
      end
    end

    puts "Repo: #{@repo_url}\n\n"
    hydra.run
    puts ''
    if broken_files.empty?
      puts 'All files have correct size. Hooray!'
    else
      puts "Packages with wrong file size:\n"
      puts broken_files.join("\n")
    end
  ensure
    FileUtils.rm_r(@tempdir)
  end

  protected

  def get(filename)
    uri = URI.join(@repo_url, filename)
    uri.query = @token

    response = Typhoeus.get(uri, followlocation: true)

    file = File.open(File.join(@tempdir, File.basename(filename)), 'w')
    file.write(response.body)
    file.close
    file.path
  end
end

if (!ARGV[0] || ARGV[0] == '-h' || ARGV[0] == '--help')
  puts "Usage: #{File.basename($PROGRAM_NAME)} REPO_URL"
  puts 'Authentication token can be supplied as query string, e.g.: https://repo.url/?auth_token'
  exit 1
end

uri = URI.parse(ARGV[0])

token = uri.query
uri.query = nil

RepoVerifier.new(uri.to_s, token).verify
