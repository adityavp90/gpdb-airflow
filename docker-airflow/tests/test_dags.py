# https://gist.github.com/criccomini/2862667822af7fae8b55682faef029a7

import os
import unittest

from airflow.models import DagBag


class TestDags(unittest.TestCase):
    """
    Generic tests that all DAGs in the repository should be able to pass.
    """

    def _get_dagbag(self):
        AIRFLOW_DAGS = "/usr/local/airflow/dags"
        dag_folder = AIRFLOW_DAGS
        self.assertTrue(
            dag_folder,
            'AIRFLOW_DAGS must be set to a folder that has DAGs in it.')
        return DagBag(dag_folder=dag_folder, include_examples=False)

    def test_dagbag_import(self):
        """
        Verify that Airflow will be able to import all DAGs in the repository.
        """
        dagbag = self._get_dagbag()
        self.assertFalse(
            len(dagbag.import_errors),
            'There should be no DAG failures. Got: {}'.format(dagbag.import_errors))

    # def test_templates(self):
    #     e = False
    #     try:
    #         AIRFLOW_DAGS = "/usr/local/airflow/dags"
    #         dag_folder = AIRFLOW_DAGS
    #         DagBag(dag_folder=dag_folder, include_examples=False)
    #     except TemplateNotFound:
    #         #self.fail("DAG import raised raised TemplateNotFound unexpectedly!")
    #         e = True
    #     self.assertFalse(e)