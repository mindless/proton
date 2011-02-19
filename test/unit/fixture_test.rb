require File.expand_path('../../helper', __FILE__)

class HydeTest < TestCase
  def assert_fixture_okay(path)
    # Build
    project = Hyde::Project.new(path)
    project.pages.each { |p| p.write }

    Dir[project.root('control/**/*')].each do |control|
      next  unless File.file?(control)
      var = control.sub('/control/', '/public/')
      assert File.exists?(var)
      if read(control) != read(var)
        flunk "Failed in #{var}\n" +
          "Control:\n" +
          read(control).gsub(/^/, '|    ') + "\n\n" + 
          "Variable:\n" +
          read(var).gsub(/^/, '|    ')
      end
    end
  end

  def read(file)
    File.open(file) { |f| f.read }
  end

  teardown do
    # Remove the generated
    Dir[fixture('*', 'public')].each { |dir| FileUtils.rm_rf dir }
  end

  test "fixture one" do
    assert_fixture_okay fixture('one')
  end
end