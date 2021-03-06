require 'spec_helper'

describe ProjectService do

  let(:github_user) { FactoryGirl.create(:github_user)}

  before(:each) do
    Plan.create_defaults
    @orga = OrganisationService.create_new_for github_user
    expect( @orga.save ).to be_truthy
  end

  describe "index" do
    it 'returns the single project for a user' do
      project = ProjectFactory.create_new github_user, nil, true, @orga
      expect( project.save ).to be_truthy
      expect( ProjectService.index(github_user, {:organisation => @orga.ids}).count ).to eq(1)
    end
    it 'returns the single parent project for a user' do
      project = ProjectFactory.create_new github_user, nil, true, @orga
      expect( project.save ).to be_truthy
      project2 = ProjectFactory.create_new github_user, nil, true, @orga
      project2.parent_id = project.ids
      project2.save
      expect( ProjectService.index(github_user).count ).to eq(1)
    end
    it 'returns 2 projects for a user' do
      project = ProjectFactory.create_new github_user, nil, true, @orga
      expect( project.save ).to be_truthy
      project2 = ProjectFactory.create_new github_user, nil, true, @orga
      expect( project2.save ).to be_truthy
      expect( ProjectService.index(github_user).count ).to eq(2)
    end
    it 'returns 2 public projects for a user' do
      user  = UserFactory.create_new 1
      user2 = UserFactory.create_new 2
      project = ProjectFactory.create_new user, nil, true, @orga
      project.public = true
      project.name = 'bbb'
      project.parent_id = nil
      project.save
      project2 = ProjectFactory.create_new user2
      project2.public = true
      project2.name = "aaa"
      project2.parent_id = nil
      expect( project2.save ).to be_truthy
      projects = ProjectService.index(user, {:scope => 'all_public'}, 'name')
      expect( projects.count ).to eq(2)
      expect( projects.first.name ).to eq('aaa')
    end
    it 'returns public projects for a user filtered by language' do
      user  = UserFactory.create_new 1
      user2 = UserFactory.create_new 2
      project = ProjectFactory.create_new user, nil, true, @orga
      project.public = true
      project.language = 'Ruby'
      project.parent_id = nil
      project.save
      project2 = ProjectFactory.create_new user2
      project2.public = true
      project2.language = 'Java'
      project2.parent_id = nil
      expect( project2.save ).to be_truthy
      projects = ProjectService.index(user, {:scope => 'all_public', :language => 'Java'})
      expect( projects.count ).to eq(1)
      expect( projects.first.language ).to eq('Java')
    end
    it 'returns empty list for a user filtered by language' do
      user  = UserFactory.create_new 1
      user2 = UserFactory.create_new 2
      project = ProjectFactory.create_new user, nil, true, @orga
      project.public = true
      project.language = 'Ruby'
      project.parent_id = nil
      project.save
      project2 = ProjectFactory.create_new user2
      project2.public = true
      project2.language = 'Java'
      project2.parent_id = nil
      expect( project2.save ).to be_truthy
      projects = ProjectService.index(user, {:scope => 'user', :language => 'Java'})
      expect( projects.count ).to eq(0)
    end
    it 'returns public projects for a user filtered by name' do
      user  = UserFactory.create_new 1
      user2 = UserFactory.create_new 2
      project = ProjectFactory.create_new user, nil, true, @orga
      project.public = true
      project.name = 'hansi_binsi'
      project.language = 'Ruby'
      project.parent_id = nil
      project.save
      project2 = ProjectFactory.create_new user2, nil, true, @orga
      project2.public = true
      project2.language = 'Java'
      project2.parent_id = nil
      expect( project2.save ).to be_truthy
      projects = ProjectService.index(user, {:scope => 'all_public', :name => project.name}, 'license_violations')
      expect( projects.count ).to eq(1)
      expect( projects.first.language ).to eq('Ruby')
      expect( projects.first.name ).to eq(project.name)
    end
  end


  describe "all_projects" do
    it 'returns all projects for the user' do
      user = UserFactory.create_new

      orga1 = Organisation.new(:name => 'orga1', :plan => Plan.micro)
      expect( orga1.save ).to be_truthy

      orga2 = Organisation.new(:name => 'orga2', :plan => Plan.micro)
      expect( orga2.save ).to be_truthy

      orga3 = Organisation.new(:name => 'orga3', :plan => Plan.micro)
      expect( orga3.save ).to be_truthy

      orga1_team1 = Team.new(:name => 'team1', :organisation_id => orga1.ids)
      expect( orga1_team1.save ).to be_truthy
      expect( orga1_team1.add_member(user) ).to be_truthy
      expect( OrganisationService.index( user ).count ).to eq(1)

      orga1_project = ProjectFactory.create_new user, nil, true, @orga
      orga1_project.user_id = nil
      orga1_project.organisation_id = orga1.ids
      orga1_project.team_ids = [orga1_team1.ids]
      expect( orga1_project.save ).to be_truthy

      expect( ProjectService.all_projects(user).keys.count ).to eq(2)
      expect( ProjectService.all_projects(user).keys[0] ).to eq(user.fullname)
      expect( ProjectService.all_projects(user).keys[1] ).to eq("#{orga1.name}/#{orga1_team1.name}")

      orga1_team2 = Team.new(:name => 'team2', :organisation_id => orga1.ids)
      expect( orga1_team2.save ).to be_truthy
      expect( orga1_team2.add_member(user) ).to be_truthy

      orga1_project2 = ProjectFactory.create_new user, nil, true, @orga
      orga1_project2.user_id = nil
      orga1_project2.organisation_id = orga1.ids
      orga1_project2.team_ids = [orga1_team2.ids]
      expect( orga1_project2.save ).to be_truthy

      expect( ProjectService.all_projects(user).keys.count ).to eq(3)
      expect( ProjectService.all_projects(user).keys[0] ).to eq(user.fullname)
      expect( ProjectService.all_projects(user).keys[2] ).to eq("#{orga1.name}/#{orga1_team2.name}")

      orga1_team3 = Team.new(:name => 'team3', :organisation_id => orga1.ids)
      expect( orga1_team3.save ).to be_truthy

      orga1_project3 = ProjectFactory.create_new user, nil, true, @orga
      orga1_project3.user_id = nil
      orga1_project3.organisation_id = orga1.ids
      orga1_project3.team_ids = [orga1_team2.ids]
      expect( orga1_project3.save ).to be_truthy

      # still 3, because user is not part of the new team!
      expect( ProjectService.all_projects(user).keys.count ).to eq(3)

      orga2_team1 = Team.new(:name => 'team1', :organisation_id => orga2.ids)
      expect( orga2_team1.save ).to be_truthy
      expect( orga2_team1.add_member(user) ).to be_truthy

      orga2_project1 = ProjectFactory.create_new user, nil, true, @orga
      orga2_project1.user_id = nil
      orga2_project1.organisation_id = orga2.ids
      orga2_project1.team_ids = [orga2_team1.ids]
      expect( orga2_project1.save ).to be_truthy

      expect( ProjectService.all_projects(user).keys.count ).to eq(4)
      expect( ProjectService.all_projects(user).keys[3] ).to eq("#{orga2.name}/#{orga2_team1.name}")
    end
  end


  describe "corresponding_file" do
    it "returns nil for pom.xml" do
      expect( described_class.corresponding_file('pom.xml') ).to be_nil
    end
    it "returns Gemfile.lock" do
      expect( described_class.corresponding_file('Gemfile') ).to eq('Gemfile.lock')
    end
    it "returns composer.lock" do
      expect( described_class.corresponding_file('composer.json') ).to eq('composer.lock')
    end
    it "returns Podfile.lock" do
      expect( described_class.corresponding_file('Podfile') ).to eq('Podfile.lock')
    end
  end

  describe "remove_temp_projects" do
    it 'removes all temp projects' do
      user = UserFactory.create_new
      project = ProjectFactory.create_new user
      project.save
      project2 = ProjectFactory.create_new user
      project2.temp = true
      project2.save
      expect( Project.count ).to eq(2)
      ProjectService.remove_temp_projects
      expect( Project.count ).to eq(1)
    end
  end

  describe "type_by_filename" do
    it "returns RubyGems. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_Gemfile?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"
      url2 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_Gemfile.lock?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"
      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_RUBYGEMS)
      expect( described_class.type_by_filename(url2) ).to eql(Project::A_TYPE_RUBYGEMS)
      expect( described_class.type_by_filename("Gemfile") ).to eql(Project::A_TYPE_RUBYGEMS)
      expect( described_class.type_by_filename("Gemfile.lock") ).to eql(Project::A_TYPE_RUBYGEMS)
      expect( described_class.type_by_filename("app/Gemfile")  ).to eql(Project::A_TYPE_RUBYGEMS)
      expect( described_class.type_by_filename("app/Gemfile.lock") ).to eql(Project::A_TYPE_RUBYGEMS)
    end
    it "returns nil for wrong Gemfiles. OK" do
      expect( described_class.type_by_filename("Gemfile/") ).to be_nil
      expect( described_class.type_by_filename("Gemfile.lock/a") ).to be_nil
      expect( described_class.type_by_filename("app/Gemfile/new.html") ).to be_nil
      expect( described_class.type_by_filename("app/Gemfile.lock/new") ).to be_nil
    end
    it "returns nil for wrong CMakeLists.txt. OK" do
      expect( described_class.type_by_filename("CMakeLists.txt") ).to be_nil
    end

    it "returns Composer. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_composer.json?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"
      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_COMPOSER)
      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_COMPOSER)
      expect( described_class.type_by_filename("composer.json") ).to eql(Project::A_TYPE_COMPOSER)
      expect( described_class.type_by_filename("composer.lock") ).to eql(Project::A_TYPE_COMPOSER)
      expect( described_class.type_by_filename("app/composer.json") ).to eql(Project::A_TYPE_COMPOSER)
      expect( described_class.type_by_filename("app/composer.lock") ).to eql(Project::A_TYPE_COMPOSER)
    end

    it "returns nil for wrong composer. OK" do
      expect( described_class.type_by_filename("composer.json/")  ).to be_nil
      expect( described_class.type_by_filename("composer.lock/a") ).to be_nil
      expect( described_class.type_by_filename("app/composer.json/new.html") ).to be_nil
      expect( described_class.type_by_filename("app/composer.lock/new")      ).to be_nil
    end

    it "returns PIP. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_requirements.txt?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"
      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_PIP)
      expect( described_class.type_by_filename("requirements.txt") ).to eql(Project::A_TYPE_PIP)
      expect( described_class.type_by_filename("app/requirements.txt") ).to eql(Project::A_TYPE_PIP)
    end

    it "returns nil for wrong pip file" do
      expect( described_class.type_by_filename("requirements.txta") ).to be_nil
      expect( described_class.type_by_filename("app/requirements.txt/new") ).to be_nil
    end

    it "returns NPM. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_package.json?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"

      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_NPM)
      expect( described_class.type_by_filename("package.json") ).to eql(Project::A_TYPE_NPM)
      expect( described_class.type_by_filename("app/package.json") ).to eql(Project::A_TYPE_NPM)
    end

    it "returns nil for wrong npm file" do
      expect( described_class.type_by_filename("package.jsona") ).to be_nil
      expect( described_class.type_by_filename("app/package.json/new") ).to be_nil
    end

    it "returns Gradle. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_dep.gradle?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"

      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_GRADLE)
      expect( described_class.type_by_filename("dependencies.gradle") ).to eql(Project::A_TYPE_GRADLE)
      expect( described_class.type_by_filename("app/dependencies.gradle") ).to eql(Project::A_TYPE_GRADLE)
      expect( described_class.type_by_filename("app/deps.gradle") ).to eql(Project::A_TYPE_GRADLE)
    end

    it "returns nil for wrong gradle file" do

      expect( described_class.type_by_filename("dependencies.gradlea") ).to be_nil
      expect( described_class.type_by_filename("dep.gradleo1") ).to be_nil
      expect( described_class.type_by_filename("app/dependencies.gradle/new") ).to be_nil
      expect( described_class.type_by_filename("app/dep.gradle/new") ).to be_nil
    end

    it "returns Maven2. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_pom.xml?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"

      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_MAVEN2)
      expect( described_class.type_by_filename("app/pom.xml") ).to eql(Project::A_TYPE_MAVEN2)
    end

    it "returns nil for wrong maven2 file" do
      expect( described_class.type_by_filename("pom.xmla") ).to be_nil
      expect( described_class.type_by_filename("app/pom.xml/new") ).to be_nil
    end

    it "returns Lein. OK" do
      url1 = "http://localhost:4567/veye_dev_projects/i5lSWS951IxJjU1rurMg_project.clj?AWSAccessKeyId=123&Expires=1360525084&Signature=HRPsn%2Bai%2BoSjm8zqwZFRtzxJvvE%3D"

      expect( described_class.type_by_filename(url1) ).to eql(Project::A_TYPE_LEIN)
      expect( described_class.type_by_filename("project.clj") ).to eql(Project::A_TYPE_LEIN)
      expect( described_class.type_by_filename("app/project.clj") ).to eql(Project::A_TYPE_LEIN)
    end

    it "returns Nuget" do
      expect( described_class.type_by_filename("/project.json") ).to eql(Project::A_TYPE_NUGET)
      expect( described_class.type_by_filename("/something.nuspec") ).to eql(Project::A_TYPE_NUGET)
      expect( described_class.type_by_filename('veye.csproj') ).to eq(Project::A_TYPE_NUGET)
      expect( described_class.type_by_filename('/a/b/c/veye.csproj') ).to eq(Project::A_TYPE_NUGET)
    end

    it "returns nil for wrong Lein file" do
      expect( described_class.type_by_filename("project.clja") ).to be_nil
      expect( described_class.type_by_filename("app/project.clj/new") ).to be_nil
    end

    it "returns Cargo" do
      expect( described_class.type_by_filename("/Cargo.toml") ).to eql(Project::A_TYPE_CARGO)
      expect( described_class.type_by_filename("/Cargo.lock") ).to eql(Project::A_TYPE_CARGO)
    end

    it "returns Mix" do
      expect( described_class.type_by_filename('mix.exs') ).to eq(Project::A_TYPE_HEX)
      expect( described_class.type_by_filename('/a/b/c/mix.exs') ).to eq(Project::A_TYPE_HEX)
    end

  end


  describe "find" do
    it "returns the project with dependencies" do
      rc_1 = '200.0.0-RC1'
      zz_1 = '0.0.1'

      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_2.versions = []
      prod_2.add_version rc_1
      prod_2.version = rc_1
      prod_2.save
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1000.0.0'}
      ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => zz_1, :version_current => rc_1}
      ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => '0.0.0'}

      expect( project.dependencies.count ).to eq(3)

      project.dependencies.each do |dep|
        dep.outdated = nil
        dep.release = nil
        dep.save
      end

      project.dependencies.each do |dep|
        expect( dep.outdated ).to be_nil
        expect( dep.release ).to be_nil
      end

      proj = ProjectService.find project.id.to_s

      expect(proj.dependencies.count ).to eq(3)
      proj.dependencies.each do |dep|
        expect( dep.outdated  ).to be_nil
        expect( dep.release   ).to be_nil
      end
    end
  end

  describe 'find_child' do
    it "returns the child project with dependencies" do
      rc_1 = '200.0.0-RC1'
      zz_1 = '0.0.1'

      user     = UserFactory.create_new
      project1 = ProjectFactory.create_new user
      project2 = ProjectFactory.create_new user
      project2.parent_id = project1.id.to_s
      project2.save

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_2.versions = []
      prod_2.add_version rc_1
      prod_2.version = rc_1
      prod_2.save
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => '1000.0.0'}
      ProjectdependencyFactory.create_new project2, prod_2, true, {:version_requested => zz_1, :version_current => rc_1}
      ProjectdependencyFactory.create_new project2, prod_3, true, {:version_requested => '0.0.0'}

      expect( project2.dependencies.count ).to eq(3)
      project2.dependencies.each do |dep|
        dep.outdated = nil
        dep.release = nil
        dep.save
      end

      project2.dependencies.each do |dep|
        expect( dep.outdated  ).to be_nil
        expect( dep.release   ).to be_nil
      end

      proj = ProjectService.find_child project1.id.to_s, project2.id.to_s

      expect( proj ).not_to be_nil
      expect( proj.id.to_s ).to eq(project2.id.to_s)
      expect( proj.dependencies.count ).to eq(3)
      proj.dependencies.each do |dep|
        expect( dep.outdated  ).to be_nil
        expect( dep.release   ).to be_nil
      end
    end
  end


  describe 'store' do

    it 'stores a project' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project, prod_1, false, {:version_requested => '1.0.0'}
      ProjectdependencyFactory.create_new project, prod_2, false, {:version_requested => '0.1.0'}
      ProjectdependencyFactory.create_new project, prod_3, false, {:version_requested => '0.0.0'}

      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(0)
      expect( Projectdependency.count ).to eq(0)

      resp = described_class.store project
      expect( resp ).to be_truthy
      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(1)
      expect( Projectdependency.count ).to eq(3)
    end
  end

  describe 'summary' do

    it 'returns the summary object' do
      user     = UserFactory.create_new
      project  = ProjectFactory.create_new user
      project2 = ProjectFactory.create_new user
      project2.parent_id = project.ids
      project2.save

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project2, prod_1, true
      ProjectdependencyFactory.create_new project, prod_2, true
      ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => '0.0.0'}

      orga1 = Organisation.new(:name => 'orga1', :plan => Plan.micro)
      expect( orga1.save ).to be_truthy

      LicenseWhitelistService.create orga1, 'SuperList'
      LicenseWhitelistService.add orga1, 'SuperList', 'MIT'
      LicenseFactory.create_new prod_2, 'GPL'

      expect( LicenseWhitelist.count ).to eq(2)
      project.license_whitelist_id = LicenseWhitelist.last.ids
      expect( project.save ).to be_truthy

      add_sv prod_1

      ProjectUpdateService.update project

      summary = described_class.summary project.ids
      expect( summary ).to_not be_nil

      expect( summary[project.ids][:out_number] ).to eq(1)
      expect( summary[project.ids][:out_number_sum] ).to eq(1)
      expect( summary[project.ids][:sv_count_sum] ).to eq(1)
      expect( summary[project.ids][:sv_count] ).to eq(0)

      expect( summary[project.ids][:licenses_red] ).to eq(1)
      expect( summary[project.ids][:licenses_red_sum] ).to eq(1)

      expect( summary[project.ids][:dependencies] ).to_not be_empty
      expect( summary[project.ids][:dependencies].count ).to eq(2)

      expect( summary[project2.ids][:sv_count_sum] ).to eq(1)
      expect( summary[project2.ids][:sv_count] ).to eq(1)
      expect( summary[project2.ids][:sv] ).to_not be_empty
    end

  end
  def add_sv product
    sv = SecurityVulnerability.new({:language => product.language, :prod_key => product.prod_key, :summary => 'test'})
    sv.affected_versions << product.version
    sv.save
    version = product.version_by_number product.version
    version.sv_ids << sv.ids
    version.save
  end



  describe 'ensure_unique_ga' do
    it 'returns true because its turned off' do
      Settings.instance.projects_unique_ga = false
      expect( ProjectService.ensure_unique_ga(nil) ).to be_truthy
    end

    it 'returns true because there is no other project in db!' do
      Settings.instance.projects_unique_ga = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.group_id = "org.junit"
      project.artifact_id = 'junit'

      expect( ProjectService.ensure_unique_ga(project) ).to be_truthy
      Settings.instance.projects_unique_ga = false
    end
    it 'returns true because there is no other project in db!' do
      Settings.instance.projects_unique_ga = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.group_id = "org.junit"
      project.artifact_id = 'junit'
      project.save
      expect { ProjectService.ensure_unique_ga(project) }.to raise_exception
      Settings.instance.projects_unique_ga = false
    end
  end


  describe 'ensure_unique_gav' do
    it 'returns true because its turned off' do
      Settings.instance.projects_unique_gav = false
      expect( ProjectService.ensure_unique_gav(nil) ).to be_truthy
    end

    it 'returns true because there is no other project in db!' do
      Settings.instance.projects_unique_gav = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.group_id = "org.junit"
      project.artifact_id = 'junit'
      project.version = '1.0'
      expect( ProjectService.ensure_unique_gav(project) ).to be_truthy
      Settings.instance.projects_unique_gav = false
    end
    it 'Throws an exception because there is already a similar project in db!' do
      Settings.instance.projects_unique_gav = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.group_id = "org.junit"
      project.artifact_id = 'junit'
      project.version = '1.0'
      expect( project.save ).to be_truthy
      new_project = ProjectFactory.create_new user, nil, false
      new_project.group_id = "org.junit"
      new_project.artifact_id = 'junit'
      new_project.version = '1.0'
      expect { ProjectService.ensure_unique_gav(new_project) }.to raise_exception
      Settings.instance.projects_unique_gav = false
    end
  end


  describe 'ensure_unique_scm' do
    it 'returns true because its turned off' do
      Settings.instance.projects_unique_scm = false
      expect( ProjectService.ensure_unique_scm(nil) ).to be_truthy
    end

    it 'returns true because there is no other project in db!' do
      Settings.instance.projects_unique_scm = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.source = "github"
      project.scm_fullname = 'reiz/boom'
      project.scm_branch = 'master'
      project.s3_filename = 'pom.xml'

      expect( ProjectService.ensure_unique_scm(project) ).to be_truthy
      Settings.instance.projects_unique_scm = false
    end

    it 'returns true because there is no other project in db!' do
      Settings.instance.projects_unique_scm = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.source = "github"
      project.scm_fullname = 'reiz/boom'
      project.scm_branch = 'master'
      project.s3_filename = 'pom.xml'
      project.save
      expect( ProjectService.ensure_unique_scm(project) ).to be_truthy
      Settings.instance.projects_unique_scm = false
    end
    it 'throws an exception because there is already a project with same data' do
      Settings.instance.projects_unique_scm = true
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, false
      project.source = "github"
      project.scm_fullname = 'reiz/boom'
      project.scm_branch = 'master'
      project.s3_filename = 'pom.xml'
      project.save
      new_project = ProjectFactory.create_new user, nil, false
      new_project.source = "github"
      new_project.scm_fullname = 'reiz/boom'
      new_project.scm_branch = 'master'
      new_project.s3_filename = 'pom.xml'
      expect { ProjectService.ensure_unique_scm(new_project) }.to raise_exception
      Settings.instance.projects_unique_scm = false
    end
  end


  describe 'destroy_single' do

    it 'destroys a single project' do
      owner   = UserFactory.create_new 1023
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}
      ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => '0.1.0'}
      ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => '0.0.0'}

      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(1)
      expect( Projectdependency.count ).to eq(3)

      ProjectService.destroy_single project.id

      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(0)
      expect( Projectdependency.count ).to eq(0)
    end

  end


  describe 'destroy' do

    it 'destroys a parent project with all childs' do
      owner   = UserFactory.create_new 1023
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true
      child   = ProjectFactory.create_new user, nil, true
      child.parent_id = project.id.to_s
      child.save

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}
      ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => '0.1.0'}
      ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => '0.0.0'}

      ProjectdependencyFactory.create_new child, prod_1, true, {:version_requested => '1.0.0'}

      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(2)
      expect( Projectdependency.count ).to eq(4)

      ProjectService.destroy project

      expect( Product.count ).to eq(3)
      expect( Project.count ).to eq(0)
      expect( Projectdependency.count ).to eq(0)
    end
  end


  describe 'destroy_by' do

    it 'destroys a project' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true
      project.user_id = user.ids
      expect( project.save ).to be_truthy
      expect( project.user_id.to_s.eql?(user.ids) ).to be_truthy

      prod_1 = ProductFactory.create_new 1
      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      expect( Project.count ).to eq(1)
      ProjectService.destroy_by( user, project.ids )
      expect( Project.count ).to eq(0)
    end

    it 'throws exeception because user has no right to delete project.' do
      dude    = UserFactory.create_new 23
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      expect( Project.count ).to eq(1)
      expect { ProjectService.destroy_by(dude, project) }.to raise_exception
      expect( Project.count ).to eq(1)
    end

    it 'throws exeception because user has no right to delete project.' do
      admin   = UserFactory.create_new 23
      admin.admin = true
      admin.save
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      expect( Project.count ).to eq(1)
      ProjectService.destroy_by(admin, project)
      expect( Project.count ).to eq(0)
    end

  end


  describe 'merge_by_ga' do

    it 'merges by group and artifact id' do
      user    = UserFactory.create_new

      project = ProjectFactory.create_new user, nil, true
      project.group_id = 'com.company'
      project.artifact_id = 'project_a'
      project.save
      prod_1  = ProductFactory.create_new 1
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      project2 = ProjectFactory.create_new user, nil, true
      dep_1    = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => '1.0.0'}

      expect( Project.where(:parent_id.ne => nil).count ).to eq(0)

      response = ProjectService.merge_by_ga project.group_id, project.artifact_id, project2.id, user.id
      expect( response ).to be_truthy

      expect( Project.where(:parent_id.ne => nil).count ).to eq(1)

      project2 = Project.find project2.id.to_s
      expect( project2.parent_id ).not_to be_empty
      expect( project2.parent_id.to_s ).to eq( project.id.to_s )
    end

  end


  describe 'merge' do

    it 'merges' do
      user    = UserFactory.create_new

      project = ProjectFactory.create_new user, nil, true
      prod_1  = ProductFactory.create_new 1
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      project2 = ProjectFactory.create_new user, nil, true
      dep_1    = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => '1.0.0'}

      expect( Project.where(:parent_id.ne => nil).count ).to eq(0)

      response = ProjectService.merge project.id, project2.id, user.id
      expect( response ).to be_truthy
      expect( Project.where(:parent_id.ne => nil).count ).to eq(1)

      project2 = Project.find project2.id.to_s

      expect( project2.parent_id ).not_to be_empty
      expect( project2.parent_id.to_s ).to eq( project.id.to_s )
    end

  end


  describe 'unmerge' do

    it 'unmerges' do
      user    = UserFactory.create_new

      project = ProjectFactory.create_new user, nil, true
      prod_1  = ProductFactory.create_new 1
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      project2 = ProjectFactory.create_new user, nil, true
      dep_1    = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => '1.0.0'}

      project2.parent_id = project.id
      project2.save

      response = ProjectService.unmerge project.id, project2.id, user.id
      expect( response ).to be_truthy
      expect( Project.where(:parent_id.ne => nil).count ).to eq(0)
    end

    it 'throws exception because user is not a collaborator' do
      user    = UserFactory.create_new 1, true
      hacker  = UserFactory.create_new 2, true

      project = ProjectFactory.create_new user, nil, true
      prod_1  = ProductFactory.create_new 1
      dep_1   = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1.0.0'}

      project2 = ProjectFactory.create_new user, nil, true
      dep_1    = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => '1.0.0'}

      project2.parent_id = project.id
      project2.save

      expect { ProjectService.unmerge(project.id, project2.id, hacker.id) }.to raise_exception
    end

  end


  describe 'user_product_index_map' do

    it 'returns an empty hash because user has no projects' do
      user = UserFactory.create_new
      map = ProjectService.user_product_index_map user
      expect( map.empty?() ).to be_truthy
    end

    it 'returns an empty hash because user has no projects' do
      user = UserFactory.create_new

      project_1 = ProjectFactory.create_new user, nil, true
      project_2 = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project_1, prod_1, true, {:version_requested => '1.0.0'}
      ProjectdependencyFactory.create_new project_2, prod_2, true, {:version_requested => '0.1.0'}
      ProjectdependencyFactory.create_new project_2, prod_3, true, {:version_requested => '0.0.0'}
      ProjectdependencyFactory.create_new project_2, prod_1, true, {:version_requested => '0.0.0'}

      map = ProjectService.user_product_index_map user
      expect( map.empty? ).to be_falsey
      expect( map.count  ).to eq(3)

      key = "#{prod_1.language_esc}_#{prod_1.prod_key}"
      expect( map[key].count ).to eq(2)

      key = "#{prod_2.language_esc}_#{prod_2.prod_key}"
      expect( map[key].count ).to eq(1)
    end
  end

  describe 'outdated_dependencies' do

    it 'returns the outdated_dependencies' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1000000.0.0'}
      ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => '0.0.0'}
      ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => '0.0.0'}

      outdated_deps = ProjectService.outdated_dependencies project
      expect( outdated_deps ).not_to be_nil
      expect( outdated_deps.count ).to eq(2)
    end
  end

  describe 'unknown_licenses' do

    it 'returns an empty list' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true
      unknown = described_class.unknown_licenses( project )

      expect(unknown).to be_empty
    end
    it 'returns an empty list' do
      unknown = described_class.unknown_licenses( nil )
      expect(unknown ).to be_empty
    end

    it 'returns a list with 1 element, because the according product doesnt has a license' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => '1000000.0.0'}

      unknown = described_class.unknown_licenses( project )
      expect( unknown ).not_to be_empty
      expect( unknown.size ).to eq(1)
      expect( unknown.first.name ).to eq(prod_1.name)
    end
    it 'returns a list with 1 element, because the according product is unknown.' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      dep_1 = ProjectdependencyFactory.create_new project, nil, true, {:version_requested => '1000000.0.0'}

      unknown = described_class.unknown_licenses( project )
      expect( unknown ).not_to be_empty
      expect( unknown.size ).to eq(1)
      expect( unknown.first.id ).to eq(dep_1.id)
    end
    it 'returns a list with 1 element' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      liz_1 = LicenseFactory.create_new prod_1, 'MIT'
      liz_2 = LicenseFactory.create_new prod_2, 'MIT'

      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => prod_2.version}
      dep_3 = ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => prod_3.version}

      unknown = described_class.unknown_licenses( project )
      expect( unknown       ).not_to be_empty
      expect( unknown.size  ).to eq(1)
      expect( unknown.first.id ).to eq(dep_3.id)
    end
    it 'returns a list with 2 elements. One requested version of the product has no license.' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3

      liz_1 = LicenseFactory.create_new prod_1, 'MIT'
      liz_2 = LicenseFactory.create_new prod_2, 'MIT'

      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => '0.0.NA'}
      dep_3 = ProjectdependencyFactory.create_new project, prod_3, true, {:version_requested => prod_3.version}

      unknown = described_class.unknown_licenses( project )
      expect( unknown ).not_to be_empty
      expect( unknown.size ).to eq(2)
    end

  end


  describe 'red_licenses' do

    it 'returns an empty list because project is nil' do
      red = ProjectService.red_licenses nil
      expect( red ).to be_empty
    end
    it 'returns an empty list because project dependencies is empty' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true
      red = ProjectService.red_licenses project
      expect( red ).to be_empty
    end
    it 'returns an empty list because project has no whitelist assigned.' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1  = ProductFactory.create_new 1
      liz_1 = LicenseFactory.create_new prod_1, 'MIT'
      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => prod_1.version}

      red = ProjectService.red_licenses project
      expect( red ).to be_empty
    end
    it 'returns an empty list because Projectdependency is on whitelist' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true, @orga

      prod_1 = ProductFactory.create_new 1
      liz_1  = LicenseFactory.create_new prod_1, 'MIT'
      dep_1  = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => prod_1.version}
      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MiT'], nil, @orga
      whitelist.save
      project.license_whitelist_id = whitelist.id
      project.save

      red = ProjectService.red_licenses project
      expect( red ).to be_empty
    end
    it 'returns a list with 1 element' do
      user    = UserFactory.create_new
      project = ProjectFactory.create_new user, nil, true

      prod_1 = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2

      liz_1  = LicenseFactory.create_new prod_1, 'MIT'
      liz_2 = LicenseFactory.create_new prod_2, 'BSD'

      dep_1 = ProjectdependencyFactory.create_new project, prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project, prod_2, true, {:version_requested => prod_2.version}

      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MiT'], nil, @orga
      whitelist.save
      project.license_whitelist_id = whitelist.id
      project.save

      ProjectdependencyService.update_licenses project

      red = ProjectService.red_licenses project
      expect( red ).to_not be_empty
      expect( red.count ).to eq(1)
      expect( red.first.name ).to eq(dep_2.name)
    end

  end


  describe 'update_sums' do

    it 'updates the sums for a single project' do
      project = Project.new({ :dep_number => 5, :out_number => 1,
        :unknown_number => 2, :licenses_red => 2, :licenses_unknown => 2 })

      expect( project.dep_number_sum ).to eq(0)
      expect( project.out_number_sum ).to eq(0)
      expect( project.unknown_number_sum  ).to eq(0)
      expect( project.licenses_red_sum    ).to eq(0)
      expect( project.licenses_unknown_sum ).to eq(0)

      ProjectService.update_sums( project )

      expect( project.dep_number_sum        ).to eq( project.dep_number )
      expect( project.out_number_sum        ).to eq( project.out_number )
      expect( project.unknown_number_sum    ).to eq( project.unknown_number )
      expect( project.licenses_red_sum      ).to eq( project.licenses_red )
      expect( project.licenses_unknown_sum  ).to eq( project.licenses_unknown )
    end

    it 'updates the sums for a project with a child' do

      user     = UserFactory.create_new
      project  = ProjectFactory.create_new user, {:name => 'project_1'}, true
      project2 = ProjectFactory.create_new user, {:name => 'project_2'}, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3
      prod_4  = ProductFactory.create_new 4

      mit = LicenseFactory.create_new prod_1, 'MIT'
      gpl = LicenseFactory.create_new prod_2, 'GPL'

      dep_1 = ProjectdependencyFactory.create_new project , prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project , prod_2, true, {:version_requested => prod_2.version}
      dep_3 = ProjectdependencyFactory.create_new project2, prod_3, true, {:version_requested => '0.0.0'}
      dep_4 = ProjectdependencyFactory.create_new project2, prod_4, true, {:version_requested => '0.0.0'}
      dep_5 = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => prod_1.version}
      dep_6 = ProjectdependencyFactory.create_new project2, nil, true

      ProjectdependencyService.update_outdated!( dep_1 )
      ProjectdependencyService.update_outdated!( dep_2 )
      ProjectdependencyService.update_outdated!( dep_3 )
      ProjectdependencyService.update_outdated!( dep_4 )
      ProjectdependencyService.update_outdated!( dep_5 )

      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MIT'], nil, @orga
      expect( whitelist.save ).to be_truthy

      project.license_whitelist_id = whitelist.id
      expect( project.save ).to be_truthy

      ProjectService.update_license_numbers! project
      expect( project.licenses_red ).to eq(1)
      expect( project.licenses_red_sum ).to eq(0)
      expect( project.licenses_unknown ).to eq(0)

      project2.parent_id = project.id.to_s
      project2.license_whitelist_id = whitelist.id
      expect( project2.save ).to be_truthy
      ProjectService.update_license_numbers! project2
      expect( project2.licenses_red ).to eq(0)
      expect( project2.licenses_unknown ).to eq(3)

      ProjectService.update_sums( project )
      expect( project.licenses_red_sum      ).to eq( 1 )
      expect( project.licenses_unknown_sum  ).to eq( 3 )

      expect( project.dep_number_sum ).to eq( 5 )
      expect( project.out_number_sum ).to eq( 2 )
      expect( project.unknown_number_sum ).to eq( 1 )
    end

    it 'updates the sums for a project with a child' do

      user     = UserFactory.create_new
      project  = ProjectFactory.create_new user, {:name => 'project_1'}, true
      project2 = ProjectFactory.create_new user, {:name => 'project_2'}, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2
      prod_3  = ProductFactory.create_new 3
      prod_4  = ProductFactory.create_new 4

      mit = LicenseFactory.create_new prod_3, 'MIT'
      gpl = LicenseFactory.create_new prod_3, 'GPL'
      expect( License.count ).to eq(2)

      dep_1 = ProjectdependencyFactory.create_new project , prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project , prod_2, true, {:version_requested => prod_2.version}
      dep_3 = ProjectdependencyFactory.create_new project2, prod_3, true, {:version_requested => prod_3.version}
      dep_4 = ProjectdependencyFactory.create_new project2, prod_4, true, {:version_requested => '0.0.0'}
      dep_5 = ProjectdependencyFactory.create_new project2, prod_1, true, {:version_requested => prod_1.version}
      dep_6 = ProjectdependencyFactory.create_new project2, nil, true

      ProjectdependencyService.update_outdated!( dep_1 )
      ProjectdependencyService.update_outdated!( dep_2 )
      ProjectdependencyService.update_outdated!( dep_3 )
      ProjectdependencyService.update_outdated!( dep_4 )
      ProjectdependencyService.update_outdated!( dep_5 )

      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MIT'], nil, @orga
      whitelist.pessimistic_mode = true
      expect( whitelist.save ).to be_truthy

      project.license_whitelist_id = whitelist.id
      expect( project.save ).to be_truthy

      ProjectService.update_license_numbers! project
      expect( project.licenses_red ).to eq(0)
      expect( project.licenses_red_sum ).to eq(0)
      expect( project.licenses_unknown ).to eq(2)

      project2.parent_id = project.ids
      project2.license_whitelist_id = whitelist.id
      expect( project2.save ).to be_truthy
      ProjectService.update_license_numbers! project2
      expect( project2.licenses_red ).to eq(1)
      expect( project2.licenses_unknown ).to eq(3)

      ProjectService.update_sums( project )
      expect( project.licenses_red_sum ).to eq( 1 )
      expect( project.licenses_unknown_sum ).to eq( 4 )
    end

    it 'updates the sums for a project with a child and no LWL' do
      user     = UserFactory.create_new
      project1 = ProjectFactory.create_new user, {:name => 'project_1'}, true
      project2 = ProjectFactory.create_new user, {:name => 'project_2'}, true
      project2.parent_id = project1.ids
      expect( project2.save ).to be_truthy

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2

      mit = LicenseFactory.create_new prod_2, 'MIT'
      expect( License.count ).to eq(1)

      dep_1 = ProjectdependencyFactory.create_new project1 , prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project2 , prod_2, true, {:version_requested => prod_2.version}

      ProjectdependencyService.update_outdated!( dep_1 )
      ProjectdependencyService.update_outdated!( dep_2 )

      ProjectService.update_license_numbers! project1
      ProjectService.update_license_numbers! project2

      ProjectService.update_sums project1

      # Must be 0 because there is no license whitelist.
      expect( project1.licenses_red ).to eq(0)
      expect( project1.licenses_red_sum ).to eq(0)
    end

    it 'updates the sums for a project with LWL' do
      user     = UserFactory.create_new
      project1 = ProjectFactory.create_new user, {:name => 'project_1'}, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2

      mit = LicenseFactory.create_new prod_2, 'MIT'
      mit = LicenseFactory.create_new prod_2, 'GPL'
      expect( License.count ).to eq(2)

      dep_1 = ProjectdependencyFactory.create_new project1 , prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project1 , prod_2, true, {:version_requested => prod_2.version}

      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MIT'], nil, @orga
      expect( whitelist.save ).to be_truthy

      project1.license_whitelist_id = whitelist.id
      expect( project1.save ).to be_truthy

      ProjectdependencyService.update_outdated!( dep_1 )
      ProjectdependencyService.update_outdated!( dep_2 )

      ProjectService.update_license_numbers! project1

      ProjectService.update_sums project1

      # Must be 0 because there is no license whitelist.
      expect( project1.licenses_red ).to eq(0)
      expect( project1.licenses_red_sum ).to eq(0)
    end

    it 'updates the sums for a project with pessimistic LWL' do
      user     = UserFactory.create_new
      project1 = ProjectFactory.create_new user, {:name => 'project_1'}, true

      prod_1  = ProductFactory.create_new 1
      prod_2  = ProductFactory.create_new 2

      mit = LicenseFactory.create_new prod_2, 'MIT'
      mit = LicenseFactory.create_new prod_2, 'GPL'
      expect( License.count ).to eq(2)

      dep_1 = ProjectdependencyFactory.create_new project1 , prod_1, true, {:version_requested => prod_1.version}
      dep_2 = ProjectdependencyFactory.create_new project1 , prod_2, true, {:version_requested => prod_2.version}

      whitelist = LicenseWhitelistFactory.create_new 'OSS', ['MIT'], nil, @orga
      whitelist.pessimistic_mode = true
      expect( whitelist.save ).to be_truthy

      project1.license_whitelist_id = whitelist.id
      expect( project1.save ).to be_truthy

      ProjectdependencyService.update_outdated!( dep_1 )
      ProjectdependencyService.update_outdated!( dep_2 )

      ProjectService.update_license_numbers! project1

      ProjectService.update_sums project1

      # Must be 0 because there is no license whitelist.
      expect( project1.licenses_red ).to eq(1)
      expect( project1.licenses_red_sum ).to eq(1)
    end

  end


end
