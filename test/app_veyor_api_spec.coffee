require("./spec_helper")

appVeyprApi = require("../lib/providers/app-veyor-api")
snapshot = require("snap-shot-it")

describe "App Veyor API wrapper", ->
  context "merge variables", ->
    mergeVariables = appVeyprApi.mergeVariables

    it "merges non-overlapping lists", ->
      existing = [{name: "foo", value: 1}]
      newVars = [{name: "bar", value: 2}]
      combined = mergeVariables(existing, newVars)
      snapshot(combined)

    it "merges overlapping lists giving preference to new variables", ->
      existing = [{name: "foo", value: "old value"}]
      newVars = [{name: "foo", value: "new value"}]
      combined = mergeVariables(existing, newVars)
      snapshot(combined)

    it "combines empty list with new", ->
      existing = []
      newVars = [{name: "foo", value: "new value"}]
      combined = mergeVariables(existing, newVars)
      snapshot(combined)
