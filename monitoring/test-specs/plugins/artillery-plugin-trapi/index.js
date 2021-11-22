'use strict';

const debug = require('debug')('plugin:trapi');
const _ = require('lodash');

module.exports.Plugin = ArtilleryTrapiPlugin;

function ArtilleryTrapiPlugin(script, events) {

    this.script = script;
    this.events = events;

    const pluginConfig = script.config.plugins['translator-trapi']
    const self = this;

   // set config processors
   if (!script.config.processor) {
        script.config.processor = {};
    }

    script.scenarios.forEach(function(scenario) {
        scenario.onError = [].concat(scenario.onError || []);
        scenario.onError.push('trapiPluginOnError');
        scenario.afterResponse = [].concat(scenario.afterResponse || []);
        scenario.afterResponse.push('trapiPluginCheckExpectations');

        scenario.beforeScenario = [].concat(scenario.beforeScenario || []);
        scenario.beforeScenario.push('trapiPluginSetExpectOptions');

        scenario.afterScenario = [].concat(scenario.afterScenario || []);

    });

    script.config.processor.trapiPluginCheckExpectations = trapiPluginCheckExpectations;
    script.config.processor.trapiPluginOnError = trapiPluginOnError;

    script.config.processor.trapiPluginSetExpectOptions = function(
        userContext,
        events,
        done
      ) {
            userContext.trapiPlugin = {};
            return done();
        };

  artillery.log("TRAPI tester initialized")


}

function trapiPluginOnError(scenarioErr, requestParams, userContext, events, done) {
  artillery.log( {ok: false, scenarioErr.message});
  return done();
}


function trapiPluginCheckExpectations (
  req,
  res,
  userContext,
  events,
  done
) {
    debug('Checking trapi');
    let body = maybeParseBody(res);
    const tests = _.isArray(req.trapi) ?
        req.trapi : _.map(req.trapi, (v, k) => { const o = {}; o[k] = v; return o; })

    debug (req.trapi)
    }


function maybeParseBody(res) {
  let body;
  if (
    typeof res.body === 'string' &&
    res.headers['content-type'] &&
    (
      res.headers['content-type'].indexOf('application/json') !== -1 ||
      res.headers['content-type'].indexOf('application/problem+json') !== -1
    )
  ) {
    try {
      body = JSON.parse(res.body);
    } catch (err) {
      body = null;
    }

    return body;
  } else {
    return res.body;
  }
}