#include "cpp_package_boilerplate/package.hpp"
#include "cpp_package_boilerplate/version.hpp"

#include <gtest/gtest.h>

#include <format>
#include <string>

TEST(PackageSmokeTest, AddProducesExpectedValue) {
    EXPECT_EQ(cpp_package_boilerplate::add(20, 22), 42);
}

TEST(PackageSmokeTest, GreetIncludesName) {
    EXPECT_NE(cpp_package_boilerplate::greet("developer").find("developer"), std::string::npos);
}

TEST(PackageSmokeTest, VersionMatchesComponents) {
    using namespace cpp_package_boilerplate;
    EXPECT_EQ(version, std::format("{}.{}.{}", version_major, version_minor, version_patch));
}
