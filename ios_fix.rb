#!/usr/bin/env ruby

# Script to fix the Xcode project configuration to remove the problematic -G flag
# Usage: cd /Users/CREAMOS/Desktop/resbite_app && ruby ios_fix.rb

require 'xcodeproj'

def fix_project
  # Path to the Xcode project
  project_path = Dir.glob('ios/Runner.xcodeproj').first
  unless project_path
    puts "Error: Could not find the Xcode project"
    return
  end

  puts "Opening project at #{project_path}..."
  project = Xcodeproj::Project.open(project_path)

  # Fix all build configurations
  project.targets.each do |target|
    puts "Fixing target: #{target.name}"
    target.build_configurations.each do |config|
      puts "  Fixing build configuration: #{config.name}"
      
      # Remove '-G' flag from build settings
      ['OTHER_CFLAGS', 'OTHER_LDFLAGS', 'OTHER_SWIFT_FLAGS'].each do |flag_name|
        if config.build_settings[flag_name] && config.build_settings[flag_name].include?('-G')
          puts "    Removing -G from #{flag_name}"
          config.build_settings[flag_name] = config.build_settings[flag_name].gsub('-G', '')
        end
      end
      
      # Set minimum iOS version
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      
      # Disable bitcode
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # Disable indexing
      config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
    end
  end

  # Save the project
  project.save
  puts "Project saved successfully"
  
  # Additional instructions
  puts "\nNext steps:"
  puts "1. cd /Users/CREAMOS/Desktop/resbite_app"
  puts "2. flutter clean"
  puts "3. cd ios && rm -rf Pods Podfile.lock"
  puts "4. cd .. && flutter pub get"
  puts "5. flutter run -d \"iPhone 16\""
end

begin
  fix_project
rescue => e
  puts "Error: #{e.message}"
  puts e.backtrace.join("\n")
end