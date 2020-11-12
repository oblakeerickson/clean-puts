require 'minitest/autorun'
require_relative '../lib/clean_puts'

class TestCleanPuts < Minitest::Test

  def setup
    @clean_puts = CleanPuts::CleanPuts.new
    @sample_repo = '/tmp/clean_puts'.freeze
  end

  def setup_sample_repo
    FileUtils.remove_dir(@sample_repo) if File.directory?(@sample_repo)
    Dir.mkdir @sample_repo
    File.write("#{@sample_repo}/app.rb", "#hello world\n")
    File.write("#{@sample_repo}/lib.rb", "#test\n")
    `cd #{@sample_repo} && git init`
    `cd #{@sample_repo} && git add .`
    `cd #{@sample_repo} && git commit -m 'initial commit'`
  end

  def test_get_filename
    line = "diff --git a/file.rb b/file.rb"
    filename = @clean_puts.get_filename(line)
    assert_equal "file.rb", filename
  end

  def test_get_linenumber
    line = "@@ -12,0 +13 @@"
    linenumber = @clean_puts.get_linenumber(line)
    assert_equal 13, linenumber
  end

  def test_single_file_cleanup
    setup_sample_repo
    File.open("#{@sample_repo}/app.rb", 'a') { |f| f.write("puts 'HERE'\n") }

    diff = Dir.chdir(@sample_repo) { @clean_puts.execute_diff }
    @clean_puts.get_files_to_clean(diff)

    assert_equal true, @clean_puts.files_to_clean.has_key?('app.rb')
    assert_equal 2, @clean_puts.files_to_clean['app.rb'].first

    Dir.chdir(@sample_repo) { @clean_puts.cleanup }
    diff = Dir.chdir(@sample_repo) { @clean_puts.execute_diff }

    assert_equal "", diff
  end

  def test_multiple_file_cleanup
    setup_sample_repo
    File.open("#{@sample_repo}/app.rb", 'a') { |f| f.write("puts 'HERE'\n") }
    File.open("#{@sample_repo}/lib.rb", 'a') { |f| f.write("puts 'HERE2'\n") }

    diff = Dir.chdir(@sample_repo) { @clean_puts.execute_diff }
    @clean_puts.get_files_to_clean(diff)

    assert_equal true, @clean_puts.files_to_clean.has_key?('app.rb')
    assert_equal true, @clean_puts.files_to_clean.has_key?('lib.rb')
    assert_equal 2, @clean_puts.files_to_clean['app.rb'].first
    assert_equal 2, @clean_puts.files_to_clean['lib.rb'].first

    Dir.chdir(@sample_repo) { @clean_puts.cleanup }
    diff = Dir.chdir(@sample_repo) { @clean_puts.execute_diff }

    assert_equal "", diff
  end

  def test_perform
    setup_sample_repo
    File.open("#{@sample_repo}/app.rb", 'a') { |f| f.write("puts 'HERE'\n") }
    File.open("#{@sample_repo}/lib.rb", 'a') { |f| f.write("puts 'HERE2'\n") }
    Dir.chdir(@sample_repo) { @clean_puts.perform }
    diff = Dir.chdir(@sample_repo) { @clean_puts.execute_diff }

    assert_equal "", diff
  end

end
