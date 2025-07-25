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

package action

import (
	"sort"
	"strings"
	"time"

	chart "helm.sh/helm/v4/pkg/chart/v2"
)

// GetMetadata is the action for checking a given release's metadata.
//
// It provides the implementation of 'helm get metadata'.
type GetMetadata struct {
	cfg *Configuration

	Version int
}

type Metadata struct {
	Name       string `json:"name" yaml:"name"`
	Chart      string `json:"chart" yaml:"chart"`
	Version    string `json:"version" yaml:"version"`
	AppVersion string `json:"appVersion" yaml:"appVersion"`
	// Annotations are fetched from the Chart.yaml file
	Annotations map[string]string `json:"annotations,omitempty" yaml:"annotations,omitempty"`
	// Labels of the release which are stored in driver metadata fields storage
	Labels       map[string]string   `json:"labels,omitempty" yaml:"labels,omitempty"`
	Dependencies []*chart.Dependency `json:"dependencies,omitempty" yaml:"dependencies,omitempty"`
	Namespace    string              `json:"namespace" yaml:"namespace"`
	Revision     int                 `json:"revision" yaml:"revision"`
	Status       string              `json:"status" yaml:"status"`
	DeployedAt   string              `json:"deployedAt" yaml:"deployedAt"`
}

// NewGetMetadata creates a new GetMetadata object with the given configuration.
func NewGetMetadata(cfg *Configuration) *GetMetadata {
	return &GetMetadata{
		cfg: cfg,
	}
}

// Run executes 'helm get metadata' against the given release.
func (g *GetMetadata) Run(name string) (*Metadata, error) {
	if err := g.cfg.KubeClient.IsReachable(); err != nil {
		return nil, err
	}

	rel, err := g.cfg.releaseContent(name, g.Version)
	if err != nil {
		return nil, err
	}

	return &Metadata{
		Name:         rel.Name,
		Chart:        rel.Chart.Metadata.Name,
		Version:      rel.Chart.Metadata.Version,
		AppVersion:   rel.Chart.Metadata.AppVersion,
		Dependencies: rel.Chart.Metadata.Dependencies,
		Annotations:  rel.Chart.Metadata.Annotations,
		Labels:       rel.Labels,
		Namespace:    rel.Namespace,
		Revision:     rel.Version,
		Status:       rel.Info.Status.String(),
		DeployedAt:   rel.Info.LastDeployed.Format(time.RFC3339),
	}, nil
}

// FormattedDepNames formats metadata.dependencies names into a comma-separated list.
func (m *Metadata) FormattedDepNames() string {
	depsNames := make([]string, 0, len(m.Dependencies))
	for _, dep := range m.Dependencies {
		depsNames = append(depsNames, dep.Name)
	}
	sort.StringSlice(depsNames).Sort()

	return strings.Join(depsNames, ",")
}
