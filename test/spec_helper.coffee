chai         = require('chai')
sinon        = require("sinon")
sinonPromise = require("sinon-as-promised")

global.expect = chai.expect

chai.use(require("sinon-chai"))

sandbox = sinon.sandbox.create()

beforeEach ->
  @sandbox = sandbox

afterEach ->
  sandbox.restore()
