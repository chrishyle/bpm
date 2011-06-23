require "spec_helper"

describe BPM::Project, "project_file_path" do

  it "should return both project file paths" do
    path = fixtures('hello_world')
    expected = File.join(path, 'hello_world.json')
    BPM::Project.project_file_path(path).should == expected
  end

  it "should return [] on a package" do
    path = fixtures('core-test')
    BPM::Project.project_file_path(path).should == nil
  end

  it "should return [] on a project with no file" do
    path = fixtures('simple_hello')
    BPM::Project.project_file_path(path).should == nil
  end

end

describe BPM::Project, "is_project_root?" do

  it "should return true for a project path" do
    BPM::Project.is_project_root?(fixtures('hello_world')).should == true
  end

  it "should return false for a package" do
    BPM::Project.is_project_root?(fixtures('core-test')).should == false
  end
  
  it "should return true for a project with no project file" do
    BPM::Project.is_project_root?(fixtures('simple_hello')).should == true
  end

end

describe BPM::Project, "nearest_project" do

  describe "standard project" do
    subject do
      fixtures('hello_world').to_s # string not Pathname
    end
    
    it "should return project instance for project path" do
      BPM::Project.nearest_project(subject).root_path.should == subject
    end

    it "should return project instance for path inside of project" do
      path = File.join subject, 'lib'
      BPM::Project.nearest_project(path).root_path.should == subject
    end
  end

  describe "simple project" do
    subject do
      fixtures('simple_hello').to_s # string not Pathname
    end
    
    it "should return project instance for project path" do
      BPM::Project.nearest_project(subject).root_path.should == subject
    end

    it "should return project instance for path inside of project" do
      path = File.join subject, 'lib'
      BPM::Project.nearest_project(path).root_path.should == subject
    end
  end

  it "should return nil for a package" do
    BPM::Project.nearest_project(fixtures('core-test')).should == nil
  end
  
end

describe BPM::Project, "project metadata" do

  describe "standard project" do
    subject do
      BPM::Project.new fixtures('hello_world')
    end

    it "should be valid" do
      subject.valid?.should == true
    end
    
    it "should get project name" do
      subject.name.should == "hello_world"
    end
    
    it "should get a project version" do
      subject.version.should == "2.0.0"
    end
    
    it "should get dependencies" do
      subject.dependencies.should == {
        "spade" => "0.5.0"
      }
    end
    
  end

  describe "simple project" do
    subject do
      BPM::Project.new fixtures('simple_hello')
    end

    it "should be valid" do
      subject.valid?.should == true
    end
    
    it "should get project name" do
      subject.name.should == "simple_hello"
    end

    
    it "should get a default version" do
      subject.version.should == "0.0.1"
    end
    
    it "should get dependencies read from bpm_packages.js file" do
      subject.dependencies.should == {
      }
    end
    
  end
  
end

