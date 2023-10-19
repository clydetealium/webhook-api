import unittest
from unittest.mock import Mock
from lambdas.jira_lambda import lambda_handler

class TestJiraLambda(unittest.TestCase):

  def test_lambda_handler_negative_nobody(self):
    event = {'no': 'body'}
    context = Mock()
    result = lambda_handler(event, context)
    
    expected_result = {
      'statusCode': 400,
      'body': 'Bad Request'
    }
    self.assertEqual(result, expected_result)
  
  def test_lambda_handler_negative_notjson(self):
    event = {'body': 'not json'}
    context = Mock()
    result = lambda_handler(event, context)
    
    self.assertEqual(result['statusCode'], 500)
  
  def test_lambda_handler(self):
    event = {'body': '{"key": "value"}'}
    context = Mock()
    result = lambda_handler(event, context)
    
    self.assertEqual(result['statusCode'], 200)

if __name__ == '__main__':
  unittest.main()
