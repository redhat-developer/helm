/*
Copyright The Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"bytes"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"helm.sh/helm/v3/internal/test/ensure"
	"helm.sh/helm/v3/pkg/helmpath"
	"helm.sh/helm/v3/pkg/repo"
	"helm.sh/helm/v3/pkg/repo/repotest"
)

func TestRepoRemove(t *testing.T) {
	ts, err := repotest.NewTempServer("testdata/testserver/*.*")
	if err != nil {
		t.Fatal(err)
	}
	defer ts.Stop()

	rootDir := ensure.TempDir(t)
	repoFile := filepath.Join(rootDir, "repositories.yaml")

	const testRepoName = "test-name"

	b := bytes.NewBuffer(nil)

	rmOpts := repoRemoveOptions{
		name:      testRepoName,
		repoFile:  repoFile,
		repoCache: rootDir,
	}

	if err := rmOpts.run(os.Stderr); err == nil {
		t.Errorf("Expected error removing %s, but did not get one.", testRepoName)
	}
	o := &repoAddOptions{
		name:     testRepoName,
		url:      ts.URL(),
		repoFile: repoFile,
	}

	if err := o.run(os.Stderr); err != nil {
		t.Error(err)
	}

	idx := filepath.Join(rootDir, helmpath.CacheIndexFile(testRepoName))

	mf, _ := os.Create(idx)
	mf.Close()

	b.Reset()

	if err := rmOpts.run(b); err != nil {
		t.Errorf("Error removing %s from repositories", testRepoName)
	}
	if !strings.Contains(b.String(), "has been removed") {
		t.Errorf("Unexpected output: %s", b.String())
	}

	if _, err := os.Stat(idx); err == nil {
		t.Errorf("Error cache file was not removed for repository %s", testRepoName)
	}

	f, err := repo.LoadFile(repoFile)
	if err != nil {
		t.Error(err)
	}

	if f.Has(testRepoName) {
		t.Errorf("%s was not successfully removed from repositories list", testRepoName)
	}
}

func TestRepoRemove_NoArguments(t *testing.T) {
	cmd := newRepoRemoveCmd(ioutil.Discard)
	if err := cmd.RunE(cmd, []string{}); err == nil {
		t.Errorf("Expected an error since no repo names were provided")
	}
}

func TestRepoRemove_MultipleRepos(t *testing.T) {
	ts, thome, err := repotest.NewTempServer("testdata/testserver/*.*")
	if err != nil {
		t.Fatal(err)
	}

	hh := helmpath.Home(thome)
	cleanup := resetEnv()
	defer func() {
		ts.Stop()
		os.RemoveAll(thome.String())
		cleanup()
	}()
	if err := ensureTestHome(hh, t); err != nil {
		t.Fatal(err)
	}

	settings.Home = thome

	repoFoo := testName + "foo"
	repoBar := testName + "bar"

	if err := addRepository(repoFoo, ts.URL(), "", "", hh, "", "", "", true); err != nil {
		t.Error(err)
	}
	if err := addRepository(repoBar, ts.URL(), "", "", hh, "", "", "", true); err != nil {
		t.Error(err)
	}

	b := bytes.NewBuffer(nil)

	cmd := newRepoRemoveCmd(b)
	if err := cmd.RunE(cmd, []string{repoFoo, repoBar}); err != nil {
		t.Error(err)
	}

	if !strings.Contains(b.String(), repoFoo) {
		t.Errorf("Expected %q in output, found: %q", repoFoo, b.String())
	}
	if !strings.Contains(b.String(), repoBar) {
		t.Errorf("Expected %q in output, found: %q", repoBar, b.String())
	}

	f, err := repo.LoadRepositoriesFile(hh.RepositoryFile())
	if err != nil {
		t.Error(err)
	}

	if f.Has(repoFoo) {
		t.Errorf("%s was not successfully removed from repositories list", repoFoo)
	}
	if f.Has(repoBar) {
		t.Errorf("%s was not successfully removed from repositories list", repoBar)
	}
}
